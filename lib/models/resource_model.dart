import 'package:healthpin/models/resource_type.dart';

class ResourceModel {
  final String id;
  final String name;
  final String description;
  final ResourceType type;
  final double latitude;
  final double longitude;
  final String address;
  final String? contactNumber;
  final String? photoUrl;
  final String? openingHours;
  final bool isVerified;
  final int upvoteCount;
  final String submittedBy; // user id
  final DateTime createdAt;

  const ResourceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.contactNumber,
    this.photoUrl,
    this.openingHours,
    required this.isVerified,
    required this.upvoteCount,
    required this.submittedBy,
    required this.createdAt,
  });

  factory ResourceModel.fromMap(Map<String, dynamic> map) {
    return ResourceModel(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      type: ResourceType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => ResourceType.clinic,
      ),
      latitude: map['latitude'],
      longitude: map['longitude'],
      address: map['address'],
      contactNumber: map['contact_number'],
      photoUrl: map['photo_url'],
      openingHours: map['opening_hours'],
      isVerified: map['is_verified'],
      upvoteCount: map['upvote_count'],
      submittedBy: map['submitted_by'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type.name,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'contact_number': contactNumber,
      'photo_url': photoUrl,
      'opening_hours': openingHours,
      'is_verified': isVerified,
      'upvote_count': upvoteCount,
      'submitted_by': submittedBy,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
