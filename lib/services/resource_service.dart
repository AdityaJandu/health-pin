import '../models/health_resource.dart';

class ResourceService {
  // Simulated backend fetch
  Future<List<HealthResource>> getNearbyResources() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    return [
      HealthResource(
        id: '1',
        name: 'City General Hospital',
        distance: '1.2 miles away',
        status: 'Open 24/7',
        type: ResourceType.hospital,
        latitude: 0.0, // Replace with real relative coordinates if needed
        longitude: 0.0,
      ),
      HealthResource(
        id: '2',
        name: 'Community Clinic',
        distance: '2.5 miles away',
        status: 'Closes at 8 PM',
        type: ResourceType.clinic,
        latitude: 0.0,
        longitude: 0.0,
      ),
      HealthResource(
        id: '3',
        name: 'Central Pharmacy',
        distance: '0.8 miles away',
        status: 'Open 24/7',
        type: ResourceType.pharmacy,
        latitude: 0.0,
        longitude: 0.0,
      ),
      HealthResource(
        id: '4',
        name: 'Eastside Medical Center',
        distance: '3.1 miles away',
        status: 'Open 24/7',
        type: ResourceType.hospital,
        latitude: 0.0,
        longitude: 0.0,
      ),
    ];
  }
}
