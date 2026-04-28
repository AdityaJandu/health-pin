import 'package:flutter/material.dart';

enum ResourceType { hospital, clinic, pharmacy }

class HealthResource {
  final String id;
  final String name;
  final String distance;
  final String status;
  final ResourceType type;
  final double latitude;
  final double longitude;

  HealthResource({
    required this.id,
    required this.name,
    required this.distance,
    required this.status,
    required this.type,
    required this.latitude,
    required this.longitude,
  });

  IconData get icon {
    switch (type) {
      case ResourceType.hospital:
        return Icons.local_hospital;
      case ResourceType.clinic:
        return Icons.medical_services;
      case ResourceType.pharmacy:
        return Icons.local_pharmacy;
    }
  }

  Color get color {
    // These could be moved to AppTheme later if needed
    switch (type) {
      case ResourceType.hospital:
      case ResourceType.pharmacy:
        return const Color(0xFF1B4332); // AppTheme.primaryDeepForest
      case ResourceType.clinic:
        return const Color(0xFFD4A373); // AppTheme.accentClayOrange
    }
  }
}
