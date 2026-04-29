import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/services/location_permission_service.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/ui/home/widgets/resource_search_bar.dart';
import 'package:healthpin/ui/resources/widgets/resource_list_states.dart';
import 'package:healthpin/ui/resources/widgets/resource_list_view.dart';

class ListResourceScreen extends StatefulWidget {
  const ListResourceScreen({super.key});

  @override
  State<ListResourceScreen> createState() => _ListResourceScreenState();
}

class _ListResourceScreenState extends State<ListResourceScreen> {
  final ResourceService _resourceService = ResourceService();
  StreamSubscription<List<ResourceModel>>? _resourceSubscription;

  Position? _currentPosition;
  String? _errorMessage;
  bool _isResourcesLoading = true;
  List<ResourceModel> _resources = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _resourceSubscription?.cancel();
    super.dispose();
  }

  void _initializeData() {
    setState(() {
      _isResourcesLoading = true;
      _errorMessage = null;
      _resources = [];
    });

    _fetchLocation();
    _setupResourceStream();
  }

  Future<void> _fetchLocation() async {
    try {
      final position = await LocationPermissionService().getCurrentLocation();

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        if (_resources.isNotEmpty) {
          _resources = _sortByDistance(_resources);
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  void _setupResourceStream() {
    _resourceSubscription?.cancel();
    _resourceSubscription = _resourceService.streamResources().listen(
      (resources) {
        if (!mounted) return;
        setState(() {
          _resources = _currentPosition != null
              ? _sortByDistance(resources)
              : resources;
          _isResourcesLoading = false;
        });
      },
      onError: (e) {
        if (!mounted) return;
        setState(() {
          _errorMessage = 'Error loading resources: $e';
          _isResourcesLoading = false;
        });
      },
    );

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted && _isResourcesLoading) {
        setState(() => _isResourcesLoading = false);
      }
    });
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
    if (_currentPosition == null) return 'Locating...';

    final meters = _distanceToResource(resource);
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m away';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)}km away';
    }
  }

  List<ResourceModel> _getFilteredResources() {
    if (_searchQuery.isEmpty) return _resources;
    return _resources.where((resource) {
      final query = _searchQuery.toLowerCase();
      return resource.name.toLowerCase().contains(query) ||
          resource.address.toLowerCase().contains(query) ||
          resource.type.name.toLowerCase().contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredResources = _getFilteredResources();

    return Column(
      children: [
        _buildSearchHeader(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Available Resources',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryDeepForest,
                    letterSpacing: -0.3,
                  ),
                ),
                Text(
                  'Showing active locations in your area',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.outline,
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(child: _buildContent(filteredResources)),
      ],
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 4, 4, 2),
      child: ResourceSearchBar(
        onChanged: (value) => setState(() => _searchQuery = value),
      ),
    );
  }

  Widget _buildContent(List<ResourceModel> filteredResources) {
    if (_errorMessage != null) {
      return ResourceErrorState(
        errorMessage: _errorMessage!,
        onRetry: _initializeData,
      );
    }

    if (_isResourcesLoading) {
      return const ResourceLoadingSkeleton();
    }

    if (filteredResources.isEmpty) {
      return ResourceEmptyState(searchQuery: _searchQuery);
    }

    return ResourceListView(
      resources: filteredResources,
      distanceFormatter: _formatDistance,
      onResourceTap: (resource) {},
    );
  }
}

