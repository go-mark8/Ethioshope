import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
 // final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  // Placeholder for Google Sign In
  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    // Note: Real Google Sign-in requires the google_sign_in package setup.
    // This is a placeholder that simulates a delay.
    await Future.delayed(const Duration(seconds: 2)); 
    
    setState(() => _isLoading = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Google Sign-In not fully configured yet")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            const Text(
              "ETHIO🛍",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryGreen,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Buy, Sell, and Find Jobs in Ethiopia",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const Spacer(),
            
            // Google Button
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _signInWithGoogle,
              icon: const Icon(Icons.g_mobiledata, size: 28),
              label: const Text("Continue with Google"),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: const BorderSide(color: Colors.grey),
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            
            // Phone Button (Visual Only)
            ElevatedButton.icon(
              onPressed: () {
                // Future implementation: Navigate to OTP Screen
              },
              icon: const Icon(Icons.phone),
              label: const Text("Continue with Phone Number"),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
