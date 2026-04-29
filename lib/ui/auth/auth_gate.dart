import 'package:flutter/material.dart';
import 'package:healthpin/ui/dashboard/screens/dash_board.dart';
import 'package:healthpin/ui/auth/screens/sign_up_screen.dart';
import 'package:healthpin/ui/auth/screens/splash_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen();
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text("Error: ${snapshot.error}")),
          );
        }
        final session = snapshot.data?.session;
        if (session == null) {
          return const SignUpScreen();
        } else {
          return const DashBoard();
        }
      },
    );
  }
}

