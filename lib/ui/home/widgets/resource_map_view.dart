import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/theme/app_theme.dart';
import 'package:latlong2/latlong.dart';

class ResourceMapView extends StatelessWidget {
  final Position currentPosition;
  final List<ResourceModel> resources;
  final MapController mapController;
  final ResourceModel? selectedResource;
  final double markerScale;
  final VoidCallback? onMapReady;
  final ValueChanged<ResourceModel?> onMarkerTap;

  const ResourceMapView({
    super.key,
    required this.currentPosition,
    required this.resources,
    required this.mapController,
    required this.selectedResource,
    required this.markerScale,
    required this.onMarkerTap,
    this.onMapReady,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: LatLng(
          currentPosition.latitude,
          currentPosition.longitude,
        ),
        initialZoom: 13,
        onMapReady: onMapReady,
        onTap: (_, _) => onMarkerTap(null),
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.healthpin',
        ),
        MarkerLayer(
          markers: [
            // ── User location marker ──────────────────────────────────
            Marker(
              point: LatLng(
                currentPosition.latitude,
                currentPosition.longitude,
              ),
              width: 56,
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer pulse ring
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentClayOrange.withValues(alpha: 0.15),
                      border: Border.all(
                        color: AppTheme.accentClayOrange.withValues(alpha: 0.35),
                        width: 1.5,
                      ),
                    ),
                  ),
                  // Inner dot
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.accentClayOrange,
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.accentClayOrange.withValues(alpha: 0.5),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Resource markers ──────────────────────────────────────
            ...resources.map((resource) {
              final isSelected = selectedResource?.id == resource.id;
              return Marker(
                point: LatLng(resource.latitude, resource.longitude),
                width: isSelected ? 64 : 52,
                height: isSelected ? 64 : 52,
                child: GestureDetector(
                  onTap: () => onMarkerTap(resource),
                  child: Transform.scale(
                    scale: markerScale.clamp(0.0, 1.0),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: isSelected ? 56 : 44,
                      height: isSelected ? 56 : 44,
                      decoration: BoxDecoration(
                        color: isSelected ? resource.type.color : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: resource.type.color,
                          width: isSelected ? 0 : 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: resource.type.color.withValues(alpha: 
                              isSelected ? 0.45 : 0.2,
                            ),
                            blurRadius: isSelected ? 16 : 8,
                            spreadRadius: isSelected ? 2 : 0,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Icon(
                        resource.type.icon,
                        color: isSelected ? Colors.white : resource.type.color,
                        size: isSelected ? 26 : 20,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
      ],
    );
  }
}
