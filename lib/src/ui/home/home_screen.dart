import 'package:ethio_shop/src/providers/theme_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  // Function to handle user logout
  Future<void> _signOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      // After signing out, navigate back to the authentication screen
      Navigator.pushNamedAndRemoveUntil(context, '/auth', (route) => false);
    } catch (e) {
      // Handle potential errors during sign-out
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error signing out: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home"),
        automaticallyImplyLeading: false,
        actions: [
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return IconButton(
                icon: Icon(themeProvider.themeMode == ThemeMode.dark
                    ? Icons.dark_mode
                    : Icons.light_mode),
                onPressed: () {
                  themeProvider.toggleTheme(themeProvider.themeMode == ThemeMode.light);
                },
              );
            },
          ),
          IconButton(icon: const Icon(Icons.logout), onPressed: () => _signOut(context)),
        ],
      ),
      body: const Center(child: Text("Welcome, you are logged in!")),
    );
  }
}