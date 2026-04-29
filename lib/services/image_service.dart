import 'package:supabase_flutter/supabase_flutter.dart';

class ImageService {
  final storage = Supabase.instance.client.storage.from('healthcare');

  Future<String> uploadImage(dynamic image, String path) async {
    await storage.uploadBinary(path, image);
    final response = storage.getPublicUrl(path);
    return response;
  }
}
