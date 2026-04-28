import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final SupabaseClient _supabaseClient = Supabase.instance.client;

  Future<AuthResponse> signInUsingEmail(String email, String password) async {
    return await _supabaseClient.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUpUsingEmail(String email, String password) async {
    return await _supabaseClient.auth.signUp(email: email, password: password);
  }

  Future<void> logOut() async {
    await _supabaseClient.auth.signOut();
  }

  // Get User detail:
  String? getUserId() {
    final session = _supabaseClient.auth.currentSession;
    final user = session?.user;
    return user?.id;
  }
}
