import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/models/resource_type.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthpin/services/location_permission_service.dart';
import 'package:healthpin/services/resource_service.dart';
import '../theme/app_theme.dart';
import '../components/health_card.dart';
import 'add_resource_screen.dart';

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
      // Get location first
      final position = await LocationPermissionService().determinePosition();
      setState(() => _currentPosition = position);

      // Then listen to resources stream
      _resourceService.streamResources().listen((resources) {
        if (mounted) {
          setState(() {
            _resources = resources;
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

  // Helper: icon per resource type
  IconData _iconForType(ResourceType type) {
    switch (type) {
      case ResourceType.clinic:
        return Icons.local_hospital;
      case ResourceType.pharmacy:
        return Icons.local_pharmacy;
      case ResourceType.water:
        return Icons.water_drop;
      case ResourceType.vaccine:
        return Icons.vaccines;
      case ResourceType.mentalHealth:
        return Icons.psychology;
      case ResourceType.bloodBank:
        return Icons.bloodtype;
      case ResourceType.emergency:
        return Icons.emergency;
    }
  }

  // Helper: color per resource type
  Color _colorForType(ResourceType type) {
    switch (type) {
      case ResourceType.clinic:
        return Colors.blue;
      case ResourceType.pharmacy:
        return Colors.green;
      case ResourceType.water:
        return Colors.cyan;
      case ResourceType.vaccine:
        return Colors.purple;
      case ResourceType.mentalHealth:
        return Colors.orange;
      case ResourceType.bloodBank:
        return Colors.red;
      case ResourceType.emergency:
        return Colors.deepOrange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Background
          if (_isLoading && _currentPosition == null)
            Container(
              color: AppTheme.backgroundWarmOffWhite,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primaryDeepForest,
                ),
              ),
            )
          else if (_errorMessage != null)
            Container(
              color: AppTheme.backgroundWarmOffWhite,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.location_off,
                        size: 48,
                        color: Colors.red,
                      ),
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
            )
          else if (_currentPosition != null)
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: LatLng(
                  _currentPosition!.latitude,
                  _currentPosition!.longitude,
                ),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                  userAgentPackageName: 'com.example.healthpin',
                ),
                MarkerLayer(
                  markers: [
                    // User location marker
                    Marker(
                      point: LatLng(
                        _currentPosition!.latitude,
                        _currentPosition!.longitude,
                      ),
                      width: 80,
                      height: 80,
                      child: const Icon(
                        Icons.my_location,
                        color: AppTheme.accentClayOrange,
                        size: 40,
                      ),
                    ),
                    // Resource markers
                    ..._resources.map(
                      (resource) => Marker(
                        point: LatLng(resource.latitude, resource.longitude),
                        width: 60,
                        height: 60,
                        child: Icon(
                          _iconForType(resource.type),
                          color: _colorForType(resource.type),
                          size: 32,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

          // Top Search Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: HealthCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: AppTheme.textCharcoal),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        decoration: const InputDecoration(
                          hintText: 'Search for health resources...',
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          filled: false,
                        ),
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    const Icon(Icons.filter_list, color: AppTheme.textCharcoal),
                  ],
                ),
              ),
            ),
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.25,
            maxChildSize: 0.8,
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Pull Handle
                    Center(
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppTheme.outline.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    Expanded(
                      child: _isLoading
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: AppTheme.primaryDeepForest,
                              ),
                            )
                          : _resources.isEmpty
                          ? Center(
                              child: Text(
                                'No resources nearby.\nBe the first to add one!',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            )
                          : ListView.builder(
                              controller: scrollController,
                              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                              itemCount: _resources.length + 1,
                              itemBuilder: (context, index) {
                                if (index == 0) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 16),
                                    child: Text(
                                      '${_resources.length} Nearby Resources',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                    ),
                                  );
                                }

                                final resource = _resources[index - 1];
                                final color = _colorForType(resource.type);
                                final icon = _iconForType(resource.type);

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: HealthCard(
                                    onTap: () {},
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 48,
                                          height: 48,
                                          decoration: BoxDecoration(
                                            color: color.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Icon(icon, color: color),
                                        ),
                                        const SizedBox(width: 16),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                resource.name,
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.titleMedium,
                                              ),
                                              Text(
                                                resource.address,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium
                                                    ?.copyWith(
                                                      color: AppTheme.outline,
                                                    ),
                                              ),
                                              Row(
                                                children: [
                                                  const Icon(
                                                    Icons.thumb_up_outlined,
                                                    size: 12,
                                                    color: AppTheme
                                                        .primaryDeepForest,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${resource.upvoteCount}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodySmall
                                                        ?.copyWith(
                                                          color: AppTheme
                                                              .primaryDeepForest,
                                                        ),
                                                  ),
                                                  if (resource.isVerified) ...[
                                                    const SizedBox(width: 8),
                                                    const Icon(
                                                      Icons.verified,
                                                      size: 12,
                                                      color: Colors.green,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Verified',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodySmall
                                                          ?.copyWith(
                                                            color: Colors.green,
                                                          ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'recenter',
        onPressed: () async {
          try {
            final position = await LocationPermissionService()
                .determinePosition();
            setState(() => _currentPosition = position);
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
      ),
    );
  }
}
