import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/services/location_permission_service.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/theme/app_theme.dart';

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

// ─────────────────────────────────────────────────────────────────────────────
// RESOURCE LIST VIEW
// ─────────────────────────────────────────────────────────────────────────────

class ResourceListView extends StatelessWidget {
  final List<ResourceModel> resources;
  final String Function(ResourceModel) distanceFormatter;
  final void Function(ResourceModel) onResourceTap;

  const ResourceListView({
    super.key,
    required this.resources,
    required this.distanceFormatter,
    required this.onResourceTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return ResourceListItem(
          resource: resource,
          distance: distanceFormatter(resource),
          onTap: () => onResourceTap(resource),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESOURCE LIST ITEM
// ─────────────────────────────────────────────────────────────────────────────

class ResourceListItem extends StatelessWidget {
  final ResourceModel resource;
  final String distance;
  final VoidCallback? onTap;

  const ResourceListItem({
    super.key,
    required this.resource,
    required this.distance,
    this.onTap,
  });

  String _formatTypeName(String name) {
    if (name.isEmpty) return name;
    final spaced = name
        .replaceAllMapped(RegExp(r'([A-Z])'), (match) => ' ${match.group(0)}')
        .trim();
    return '${spaced[0].toUpperCase()}${spaced.substring(1).toLowerCase()}';
  }

  @override
  Widget build(BuildContext context) {
    final color = resource.type.color;
    final icon = resource.type.icon;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ResourceCard(
        onTap: onTap,
        padding: EdgeInsets.zero,
        child: MergeSemantics(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: color.withAlpha(30),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(child: Icon(icon, color: color, size: 24)),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.thumb_up_alt_rounded,
                          size: 16,
                          color: AppTheme.outline.withAlpha(200),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${resource.upvoteCount}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.outline.withAlpha(200),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  resource.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(fontWeight: FontWeight.w700),
                                ),
                                if (resource.isVerified) ...[
                                  const SizedBox(height: 4),
                                  const _VerifiedBadge(),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: color.withAlpha(25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _formatTypeName(resource.type.name),
                              style: TextStyle(
                                fontSize: 10,
                                color: color,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _IconTextRow(
                        icon: Icons.location_on_rounded,
                        text: resource.address,
                      ),
                      if (resource.openingHours?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        _IconTextRow(
                          icon: Icons.access_time_filled_rounded,
                          text: resource.openingHours!,
                        ),
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _Pill(
                            icon: Icons.near_me_rounded,
                            label: distance,
                            color: AppTheme.primaryDeepForest,
                            semanticLabel: 'Distance: $distance',
                          ),
                          const Spacer(),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppTheme.outline.withAlpha(75),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESOURCE SEARCH BAR
// ─────────────────────────────────────────────────────────────────────────────

class ResourceSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;
  const ResourceSearchBar({super.key, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ResourceCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.search, color: AppTheme.textCharcoal),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  onChanged: onChanged,
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
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESOURCE CARD
// ─────────────────────────────────────────────────────────────────────────────

class ResourceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const ResourceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Widget cardContent = Padding(padding: padding, child: child);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: onTap != null
          ? InkWell(onTap: onTap, child: cardContent)
          : cardContent,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// RESOURCE LIST STATES
// ─────────────────────────────────────────────────────────────────────────────

class ResourceErrorState extends StatelessWidget {
  final String errorMessage;
  final VoidCallback onRetry;

  const ResourceErrorState({
    super.key,
    required this.errorMessage,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onRetry,
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
}

class ResourceEmptyState extends StatelessWidget {
  final String searchQuery;

  const ResourceEmptyState({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              searchQuery.isEmpty
                  ? 'No nearby resources found'
                  : 'No results for "$searchQuery"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              searchQuery.isEmpty
                  ? 'Try expanding your search area'
                  : 'Try a different keyword',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

class ResourceLoadingSkeleton extends StatelessWidget {
  const ResourceLoadingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
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
}

// ─────────────────────────────────────────────────────────────────────────────
// PRIVATE HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class _IconTextRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _IconTextRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppTheme.outline),
        const SizedBox(width: 3),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.outline,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Verified',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.green.withAlpha(25),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.green.withAlpha(75),
            width: 0.5,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.verified, size: 11, color: Colors.green),
            SizedBox(width: 3),
            Text(
              'Verified',
              style: TextStyle(
                fontSize: 10,
                color: Colors.green,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final String semanticLabel;

  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
    required this.semanticLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
