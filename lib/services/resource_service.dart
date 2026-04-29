import 'package:flutter/material.dart';
import 'package:healthpin/models/resource_model.dart';
import 'package:healthpin/models/resource_type.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ResourceService {
  final _database = Supabase.instance.client.from('resources');

  // Create:
  Future<void> createResource(ResourceModel newResource) async {
    try {
      await _database.insert(newResource.toMap());
    } catch (e) {
      debugPrint('Error creating resource: $e');
    }
  }

  // Read — stream all resources:
  Stream<List<ResourceModel>> streamResources() {
    return _database
        .stream(primaryKey: ['id'])
        .map((data) => data.map((map) => ResourceModel.fromMap(map)).toList());
  }

  // Read — stream by type:
  Stream<List<ResourceModel>> streamResourcesByType(ResourceType type) {
    return _database
        .stream(primaryKey: ['id'])
        .eq('type', type.name)
        .map((data) => data.map((map) => ResourceModel.fromMap(map)).toList());
  }

  // Read — get by id:
  Future<ResourceModel?> getResourceById(String resourceId) async {
    try {
      final response = await _database
          .select()
          .eq('id', resourceId)
          .maybeSingle();
      if (response == null) return null;
      return ResourceModel.fromMap(response);
    } catch (e) {
      debugPrint('Error fetching resource: $e');
      return null;
    }
  }

  // Read — get by submitted user:
  Future<List<ResourceModel>> getResourcesByUser(String userId) async {
    try {
      final response = await _database.select().eq('submitted_by', userId);
      return (response as List)
          .map((map) => ResourceModel.fromMap(map))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user resources: $e');
      return [];
    }
  }

  // Update — single field:
  Future<void> updateResourceField(
    String resourceId,
    String field,
    dynamic value,
  ) async {
    try {
      await _database.update({field: value}).eq('id', resourceId);
    } catch (e) {
      debugPrint('Error updating resource: $e');
    }
  }

  // Update — full resource:
  Future<void> updateResource(ResourceModel resource) async {
    try {
      await _database
          .update({
            'name': resource.name,
            'description': resource.description,
            'type': resource.type.name,
            'address': resource.address,
            'contact_number': resource.contactNumber,
            'photo_url': resource.photoUrl,
            'opening_hours': resource.openingHours,
          })
          .eq('id', resource.id!);
    } catch (e) {
      debugPrint('Error updating resource: $e');
    }
  }

  // Delete:
  Future<void> deleteResource(String resourceId) async {
    try {
      await _database.delete().eq('id', resourceId);
    } catch (e) {
      debugPrint('Error deleting resource: $e');
    }
  }

  // Delete all by user:
  Future<void> deleteResourcesByUser(String userId) async {
    try {
      await _database.delete().eq('submitted_by', userId);
    } catch (e) {
      debugPrint('Error deleting user resources: $e');
    }
  }
}
