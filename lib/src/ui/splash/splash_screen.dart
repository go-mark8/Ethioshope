import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:ethio_shop/src/services/connectivity_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lottie/lottie.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // Use the new connectivity service.
  final _connectivityService = ConnectivityService();
  late final StreamSubscription<ConnectivityStatus> _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    // Start listening to connectivity changes.
    _connectivitySubscription = _connectivityService.status.listen(_handleConnectivityChange);
    // Perform the initial check after a delay.
    _delayedNavigation();
  }

  @override
  void dispose() {
    // Cancel the subscription to avoid memory leaks.
    _connectivitySubscription.cancel();
    _connectivityService.dispose();
    super.dispose();
  }

  Future<void> _delayedNavigation() async {
    // Wait for a fixed duration to ensure the splash animation is visible.
    await Future.delayed(const Duration(seconds: 3));
    _checkConnectionAndNavigate();
  }

  Future<void> _checkConnectionAndNavigate() async {
    // Manually check the initial connection status.
    final result = await Connectivity().checkConnectivity();
    final hasConnection = !result.contains(ConnectivityResult.none);
    _handleConnectivityChange(
        hasConnection ? ConnectivityStatus.connected : ConnectivityStatus.disconnected);
  }

  void _handleConnectivityChange(ConnectivityStatus status) {
    if (!mounted) return;

    if (status == ConnectivityStatus.connected) {
      // If connected, check auth state to decide the destination.
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // If user is logged in, go to the home screen.
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        // If user is not logged in, go to the auth screen.
        Navigator.pushReplacementNamed(context, '/auth');
      }
    } else {
      // If there's no connection, show the dialog.
      _showNoInternetDialog();
    }
  }

  Future<void> _showNoInternetDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("No Internet Connection"),
        content: const Text("Please check your network settings and try again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog
              // Immediately retry the connection check upon user request.
              _checkConnectionAndNavigate();
            },
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOTTIE ANIMATION - Assuming you have a file at this path.
            // If not, replace with an Image.asset or another widget.
            Lottie.asset(
              'assets/lottie/splash_animation.json',
              width: 200,
              height: 200,
            ),
            
            const SizedBox(height: 20),
            const Text(
              "ETHIO🛍",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Color(0xFF009A44),
              ),
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(color: Color(0xFFFEDD00)),
          ],
        ),
      ),
    );
  }
}
