import 'package:ethio_shop/src/ui/auth/widgets/google_sign_in_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // Trigger the Google authentication flow.
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // If the user cancels the flow, do nothing.
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      // Obtain the auth details from the request.
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential for Firebase.
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential.
      await FirebaseAuth.instance.signInWithCredential(credential);

      // After successful sign-in, navigate to the home screen.
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to sign in with Google: ${e.toString()}")),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Spacer(),
          const Text("Welcome to ETHIO🛍", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Your one-stop online marketplace.", style: TextStyle(fontSize: 16, color: Colors.grey)),
          const Spacer(),
          GoogleSignInButton(onPressed: _signInWithGoogle, isLoading: _isLoading),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}