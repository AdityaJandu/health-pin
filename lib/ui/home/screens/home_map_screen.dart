import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthpin/services/location_permission_service.dart';
import 'package:healthpin/services/resource_service.dart';
import 'package:healthpin/ui/home/widgets/resource_bottom_sheet.dart';
import 'package:healthpin/ui/home/widgets/enhanced_search_bar.dart';
import 'package:healthpin/ui/home/widgets/type_filter_bar.dart';
import 'package:healthpin/ui/home/widgets/count_badge.dart';
import 'package:healthpin/ui/home/widgets/resource_preview_card.dart';
import 'package:healthpin/ui/home/widgets/map_icon_button.dart';
import 'package:healthpin/ui/home/widgets/resource_map_view.dart';
import 'package:healthpin/ui/home/widgets/map_states.dart';
import 'package:latlong2/latlong.dart';
import 'package:healthpin/theme/app_theme.dart';

class HomeMapScreen extends StatefulWidget {
  const HomeMapScreen({super.key});

  @override
  State<HomeMapScreen> createState() => _HomeMapScreenState();
}

class _HomeMapScreenState extends State<HomeMapScreen>
    with TickerProviderStateMixin {
  Position? _currentPosition;
  String? _errorMessage;
  bool _isLoading = true;
  List<ResourceModel> _resources = [];
  String _searchQuery = '';
  ResourceModel? _selectedResource;

  final MapController _mapController = MapController();
  final ResourceService _resourceService = ResourceService();
  StreamSubscription<List<ResourceModel>>? _resourceSubscription;
  bool _isMapReady = false;

  // Filter state
  String? _activeTypeFilter;

  // Animation controllers
  late AnimationController _fabPulseController;
  late AnimationController _markerRevealController;
  late AnimationController _selectedCardController;
  late Animation<double> _fabPulseAnim;
  late Animation<double> _markerRevealAnim;
  late Animation<double> _selectedCardAnim;

  @override
  void initState() {
    super.initState();

    _fabPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _fabPulseAnim = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _fabPulseController, curve: Curves.easeInOut),
    );

    _markerRevealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _markerRevealAnim = CurvedAnimation(
      parent: _markerRevealController,
      curve: Curves.elasticOut,
    );

    _selectedCardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    _selectedCardAnim = CurvedAnimation(
      parent: _selectedCardController,
      curve: Curves.easeOutCubic,
    );

    _initializeData();
  }

  @override
  void dispose() {
    _resourceSubscription?.cancel();
    _fabPulseController.dispose();
    _markerRevealController.dispose();
    _selectedCardController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final position = await LocationPermissionService().determinePosition();
      if (!mounted) return;
      setState(() => _currentPosition = position);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      return;
    }

    _resourceSubscription?.cancel();
    _resourceSubscription = _resourceService.streamResources().listen(
      (resources) {
        if (!mounted) return;
        setState(() {
          _resources = _sortByDistance(resources);
          _isLoading = false;
        });
        _markerRevealController.forward(from: 0);
      },
      onError: (e) {
        debugPrint('Stream error: $e');
        if (!mounted) return;
        setState(() => _isLoading = false);
      },
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && _isLoading) setState(() => _isLoading = false);
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
    return [
      ...resources,
    ]..sort((a, b) => _distanceToResource(a).compareTo(_distanceToResource(b)));
  }

  String _formatDistance(ResourceModel resource) {
    final meters = _distanceToResource(resource);
    return meters < 1000
        ? '${meters.toStringAsFixed(0)}m'
        : '${(meters / 1000).toStringAsFixed(1)}km';
  }

  List<ResourceModel> _getFilteredResources() {
    var list = _resources;
    if (_activeTypeFilter != null) {
      list = list.where((r) => r.type.name == _activeTypeFilter).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where(
            (r) =>
                r.name.toLowerCase().contains(q) ||
                r.address.toLowerCase().contains(q) ||
                r.type.name.toLowerCase().contains(q),
          )
          .toList();
    }
    return list;
  }

  void _selectResource(ResourceModel? resource) {
    setState(() => _selectedResource = resource);
    if (resource != null) {
      _selectedCardController.forward(from: 0);
      if (_isMapReady) {
        _mapController.move(
          LatLng(resource.latitude, resource.longitude),
          15.5,
        );
      }
    } else {
      _selectedCardController.reverse();
    }
  }

  Set<String> _getAvailableTypes() {
    return _resources.map((r) => r.type.name).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final filteredResources = _getFilteredResources();

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // ── Map / Loading / Error ──────────────────────────────────────
          _buildMainContent(filteredResources),

          // ── Top gradient scrim ─────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 160,
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.35),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ── Search Bar ────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 12,
            left: 16,
            right: 16,
            child: EnhancedSearchBar(
              onChanged: (v) => setState(() => _searchQuery = v),
              resultCount: filteredResources.length,
            ),
          ),

          // ── Type Filter Chips ─────────────────────────────────────────
          if (_resources.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 78,
              left: 0,
              right: 0,
              child: TypeFilterBar(
                types: _getAvailableTypes(),
                activeType: _activeTypeFilter,
                resources: _resources,
                onTypeSelected: (type) => setState(
                  () => _activeTypeFilter = _activeTypeFilter == type
                      ? null
                      : type,
                ),
              ),
            ),

          // ── Resource Count Badge ──────────────────────────────────────
          if (!_isLoading && _currentPosition != null)
            Positioned(
              bottom: 230,
              left: 20,
              child: CountBadge(count: filteredResources.length),
            ),

          // ── Selected Resource Preview Card ────────────────────────────
          if (_selectedResource != null)
            Positioned(
              bottom: 200,
              left: 16,
              right: 72,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, 0.4),
                  end: Offset.zero,
                ).animate(_selectedCardAnim),
                child: FadeTransition(
                  opacity: _selectedCardAnim,
                  child: ResourcePreviewCard(
                    resource: _selectedResource!,
                    distance: _formatDistance(_selectedResource!),
                    onDismiss: () => _selectResource(null),
                  ),
                ),
              ),
            ),

          // ── Bottom Sheet ──────────────────────────────────────────────
          if (_currentPosition != null)
            Positioned.fill(
              child: ResourceBottomSheet(
                isLoading: _isLoading,
                resources: filteredResources,
                distanceFormatter: _formatDistance,
              ),
            ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildMainContent(List<ResourceModel> filteredResources) {
    if (_errorMessage != null && _currentPosition == null) {
      return MapErrorState(message: _errorMessage!, onRetry: _initializeData);
    }

    if (_currentPosition == null) {
      return const MapLoadingState();
    }

    return AnimatedBuilder(
      animation: _markerRevealAnim,
      builder: (context, _) {
        return ResourceMapView(
          currentPosition: _currentPosition!,
          resources: filteredResources,
          mapController: _mapController,
          selectedResource: _selectedResource,
          markerScale: _markerRevealAnim.value,
          onMapReady: () {
            if (mounted) setState(() => _isMapReady = true);
          },
          onMarkerTap: _selectResource,
        );
      },
    );
  }

  Widget _buildFAB() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Zoom in
        MapIconButton(
          icon: Icons.add,
          onTap: () {
            final zoom = _mapController.camera.zoom;
            _mapController.move(_mapController.camera.center, zoom + 1);
          },
        ),
        const SizedBox(height: 8),
        // Zoom out
        MapIconButton(
          icon: Icons.remove,
          onTap: () {
            final zoom = _mapController.camera.zoom;
            _mapController.move(_mapController.camera.center, zoom - 1);
          },
        ),
        const SizedBox(height: 12),
        // Re-center (pulsing)
        ScaleTransition(
          scale: _fabPulseAnim,
          child: FloatingActionButton(
            heroTag: 'recenter',
            onPressed: _recenter,
            backgroundColor: AppTheme.accentClayOrange,
            foregroundColor: Colors.white,
            elevation: 6,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.my_location_rounded, size: 24),
          ),
        ),
      ],
    );
  }

  Future<void> _recenter() async {
    _fabPulseController.stop();
    try {
      final position = await LocationPermissionService().determinePosition();
      if (!mounted) return;
      setState(() {
        _currentPosition = position;
        _resources = _sortByDistance(_resources);
      });
      if (_isMapReady) {
        _mapController.move(LatLng(position.latitude, position.longitude), 15);
      }
    } catch (e) {
      debugPrint('Recenter error: $e');
    } finally {
      if (mounted) _fabPulseController.repeat(reverse: true);
    }
  }
}
