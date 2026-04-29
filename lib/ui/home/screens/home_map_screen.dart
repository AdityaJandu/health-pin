import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthpin/services/location_permission_service.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/ui/home/widgets/resource_bottom_sheet.dart';
import 'package:healthpin/ui/home/widgets/resource_map_view.dart';
import 'package:healthpin/ui/home/widgets/resource_search_bar.dart';
import 'package:latlong2/latlong.dart';
import 'package:healthpin/theme/app_theme.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen> {
  Position? _currentPosition;
  String? _errorMessage;
  bool _isLoading = true;
  List<ResourceModel> _resources = [];
  final MapController _mapController = MapController();
  final ResourceService _resourceService = ResourceService();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final position = await LocationPermissionService().determinePosition();
      setState(() => _currentPosition = position);

      _resourceService.streamResources().listen((resources) {
        if (mounted) {
          setState(() {
            _resources = _sortByDistance(resources);
            _isLoading = false;
          });
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  double _distanceToResource(ResourceModel resource) {
    if (_currentPosition == null) return 0;
    return Geolocator.distanceBetween(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      resource.latitude,
      resource.longitude,
    );
  }

  List<ResourceModel> _sortByDistance(List<ResourceModel> resources) {
    if (_currentPosition == null) return resources;
    final sorted = [...resources];
    sorted.sort(
      (a, b) => _distanceToResource(a).compareTo(_distanceToResource(b)),
    );
    return sorted;
  }

  String _formatDistance(ResourceModel resource) {
    final meters = _distanceToResource(resource);
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m away';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km away';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background/Map
          _buildMainContent(),

          // Overlays
          const ResourceSearchBar(),

          if (_currentPosition != null)
            ResourceBottomSheet(
              isLoading: _isLoading,
              resources: _resources,
              distanceFormatter: _formatDistance,
            ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildMainContent() {
    if (_isLoading && _currentPosition == null) {
      return Container(
        color: AppTheme.backgroundWarmOffWhite,
        child: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryDeepForest),
        ),
      );
    }

    if (_errorMessage != null) {
      return Container(
        color: AppTheme.backgroundWarmOffWhite,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.location_off, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _initializeData,
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_currentPosition != null) {
      return ResourceMapView(
        currentPosition: _currentPosition!,
        resources: _resources,
        mapController: _mapController,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      heroTag: 'recenter',
      onPressed: () async {
        try {
          final position = await LocationPermissionService()
              .determinePosition();
          setState(() {
            _currentPosition = position;
            _resources = _sortByDistance(_resources);
          });
          _mapController.move(
            LatLng(position.latitude, position.longitude),
            15,
          );
        } catch (e) {
          debugPrint(e.toString());
        }
      },
      backgroundColor: AppTheme.accentClayOrange,
      foregroundColor: Colors.white,
      child: const Icon(Icons.location_searching),
    );
  }
}
