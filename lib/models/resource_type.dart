import 'package:flutter/material.dart';

enum ResourceType {
  clinic,
  pharmacy,
  water,
  vaccine,
  mentalHealth,
  bloodBank,
  emergency;

  IconData get icon {
    switch (this) {
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

  Color get color {
    switch (this) {
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
}
