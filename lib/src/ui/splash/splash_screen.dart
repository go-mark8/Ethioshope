import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart'; // Fixed import
import 'package:lottie/lottie.dart'; // Fixed import
import 'dart:async';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkInternetAndNavigate();
  }

  Future<void> _checkInternetAndNavigate() async {
    // 1. Check for Internet Connection
    var connectivityResult = await (Connectivity().checkConnectivity());
    
    // Simulate a delay for the splash animation (3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog();
    } else {
      // 2. Navigate to Home/Auth based on your app logic
      // Note: Make sure '/auth' route is defined in main.dart
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/auth');
      }
    }
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("No Internet"),
        content: const Text("Please check your connection and try again."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _checkInternetAndNavigate(); // Retry
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
            // LOTTIE ANIMATION
            // If you have an animation file, uncomment the lines below:
            // Lottie.asset(
            //   'assets/lottie/splash_animation.json', 
            //   width: 200, 
            //   height: 200
            // ),
            
            // For now, we use a simple Icon until you add the JSON file
            const Icon(Icons.shopping_bag, size: 100, color: Color(0xFF009A44)),
            
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
