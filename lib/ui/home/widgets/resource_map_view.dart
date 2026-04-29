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

  const ResourceMapView({
    super.key,
    required this.currentPosition,
    required this.resources,
    required this.mapController,
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
                currentPosition.latitude,
                currentPosition.longitude,
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
            ...resources.map(
              (resource) => Marker(
                point: LatLng(resource.latitude, resource.longitude),
                width: 60,
                height: 60,
                child: Icon(
                  resource.type.icon,
                  color: resource.type.color,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
