import 'package:healthpin/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserDatabase {
  final _database = Supabase.instance.client.from('users');

  // Create:
  Future createUser(UserModel newUser) async {
    await _database.insert(newUser.toMap());
  }

  // Read:
  Stream<List<UserModel>> streamUsers() {
    return Supabase.instance.client
        .from('users')
        .stream(primaryKey: ['id'])
        .map((data) => data.map((map) => UserModel.fromMap(map)).toList());
  }

  // Get by id:
  Future<UserModel?> getUserById(String id) async {
    try {
      final data = await _database.select().eq('id', id).single();
      return UserModel.fromMap(data);
    } catch (e) {
      return null;
    }
  }

  // Update:
  Future updateUserData(UserModel userData) async {
    await _database
        .update({
          'full_name': userData.fullName,
          'avatar_url': userData.avatarUrl,
          'organization_name': userData.organizationName,
        })
        .eq('id', userData.id);
  }

  // Delete:
  Future deleteData(String id) async {
    await _database.delete().eq('id', id);
  }
}
