import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/services/location_permission_service.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:healthpin/ui/home/widgets/resource_list_item.dart';
import 'package:healthpin/ui/home/widgets/resource_search_bar.dart';

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

  // 1. Kick off BOTH tasks at the same time without awaiting them here
  void _initializeData() {
    setState(() {
      _isResourcesLoading = true;
      _errorMessage = null;
      _resources = [];
    });

    _fetchLocation();
    _setupResourceStream();
  }

  // 2. Fetch location asynchronously
  Future<void> _fetchLocation() async {
    try {
      final position = await LocationPermissionService().getCurrentLocation();

      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        // If resources loaded before location, sort them now that we have GPS!
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

  // 3. Listen to resources asynchronously
  void _setupResourceStream() {
    _resourceSubscription?.cancel();
    _resourceSubscription = _resourceService.streamResources().listen(
      (resources) {
        if (!mounted) return;
        setState(() {
          // If we have position, sort them. Otherwise, just show them unsorted temporarily.
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

    // Timeout safety net for resources
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
    // 4. Safely handle the case where resources load faster than GPS
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
                    letterSpacing: -0.3, // Gives it a slightly more modern look
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
    // Error State
    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _initializeData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryDeepForest,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Resources Loading (Skeleton)
    // 5. Prioritize showing the skeleton for the list, ignoring the location loading state
    if (_isResourcesLoading) {
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 6,
        itemBuilder: (_, _) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    }

    // Empty State
    if (filteredResources.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty
                    ? 'No nearby resources found'
                    : 'No results for "$_searchQuery"',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty
                    ? 'Try expanding your search area'
                    : 'Try a different keyword',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      );
    }

    // List
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: filteredResources.length,
      itemBuilder: (context, index) {
        final resource = filteredResources[index];
        return ResourceListItem(
          resource: resource,
          distance: _formatDistance(resource),
          onTap: () {},
        );
      },
    );
  }
}
