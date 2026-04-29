import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/services/location_permission_service.dart';
import 'package:healthpin/services/resource_service.dart';

import 'package:healthpin/ui/resources/widgets/resource_list_header.dart';
import 'package:healthpin/ui/resources/widgets/resource_list_states.dart';
import 'package:healthpin/ui/resources/widgets/resource_list_view.dart';

// ─────────────────────────────────────────────────────────────────────────────
// LIST RESOURCE SCREEN
// ─────────────────────────────────────────────────────────────────────────────

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
        if (_resources.isNotEmpty) _resources = _sortByDistance(_resources);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = e.toString());
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
    return meters < 1000
        ? '${meters.toStringAsFixed(0)}m away'
        : '${(meters / 1000).toStringAsFixed(1)}km away';
  }

  List<ResourceModel> _getFilteredResources() {
    if (_searchQuery.isEmpty) return _resources;
    return _resources.where((r) {
      final q = _searchQuery.toLowerCase();
      return r.name.toLowerCase().contains(q) ||
          r.address.toLowerCase().contains(q) ||
          r.type.name.toLowerCase().contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredResources();

    return Column(
      children: [
        ResourceListHeader(
          count: filtered.length,
          isSearching: _searchQuery.isNotEmpty,
          hasPosition: _currentPosition != null,
          onSearchChanged: (v) => setState(() => _searchQuery = v),
        ),
        Expanded(child: _buildContent(filtered)),
      ],
    );
  }

  Widget _buildContent(List<ResourceModel> filtered) {
    if (_errorMessage != null) {
      return ResourceErrorState(
        errorMessage: _errorMessage!,
        onRetry: _initializeData,
      );
    }

    if (_isResourcesLoading) {
      return const ResourceLoadingSkeleton();
    }

    if (filtered.isEmpty) {
      return ResourceEmptyState(searchQuery: _searchQuery);
    }

    return ResourceListView(
      resources: filtered,
      distanceFormatter: _formatDistance,
      onResourceTap: (resource) {
        // Navigate to details if needed
      },
    );
  }
}
