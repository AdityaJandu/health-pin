import 'package:flutter/material.dart';
import 'package:healthpin/models/user_model.dart';
import 'package:healthpin/services/auth_service.dart';
import 'package:healthpin/services/user_database_service.dart';
import 'package:healthpin/ui/auth/auth_gate.dart';
import 'package:healthpin/ui/auth/screens/login_screen.dart';
import 'package:healthpin/components/primary_button.dart';
import 'package:healthpin/components/custom_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _cnfPasswordController = TextEditingController();

  final AuthService _authService = AuthService();
  final UserDatabase _userDatabase = UserDatabase();

  Future<void> register() async {
    setState(() {
      isLoading = true;
    });
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String cnfPassword = _cnfPasswordController.text.trim();

    if (name == "" || email == "" || password == "" || cnfPassword == "") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill up all details")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    if (password != cnfPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match!")),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      await _authService.signUpUsingEmail(email, password);
      String? userID = _authService.getUserId();

      if (userID != null && userID != '') {
        final newUser = UserModel(
          id: userID,
          fullName: name,
          email: email,
          isNgoVerified: false,
          createdAt: DateTime.now(),
        );
        await _userDatabase.createUser(newUser);

        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AuthGate()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration failed: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Join the Community',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 36,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Help build a healthier world by sharing critical resources.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 48),
              CustomTextField(
                label: 'Full Name',
                hintText: 'Enter your legal name',
                controller: _nameController,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Email Address',
                hintText: 'name@organization.org',
                keyboardType: TextInputType.emailAddress,
                controller: _emailController,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Create Password',
                hintText: 'Minimum 8 characters',
                obscureText: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 24),
              CustomTextField(
                label: 'Confirm Password',
                hintText: 'Repeat secure password',
                obscureText: true,
                controller: _cnfPasswordController,
              ),
              const SizedBox(height: 48),
              PrimaryButton(
                text: 'CREATE ACCOUNT',
                isLoading: isLoading,
                onPressed: () {
                  register();
                },
              ),
              const SizedBox(height: 32),
              Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Login',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

