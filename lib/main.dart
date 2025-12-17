import 'package:ethio_shop/src/providers/theme_provider.dart';
import 'package:ethio_shop/src/ui/auth/auth_screen.dart';
import 'package:ethio_shop/src/ui/home/home_screen.dart';
import 'package:ethio_shop/src/ui/splash/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// You must generate this file by running `flutterfire configure` in your project root.
// See: https://firebase.google.com/docs/flutter/setup
import 'firebase_options.dart';

void main() async {
  // Ensure that the Flutter engine is initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Set the app to be fullscreen (immersive sticky mode).
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Initialize Firebase for your project.
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          title: 'ETHIO🛍',
          // Light Theme Configuration
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF009A44), // Primary Ethiopian green
              secondary: const Color(0xFFFEDD00), // Secondary Ethiopian yellow
              brightness: Brightness.light,
            ),
          ),
          // Dark Theme Configuration
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.green,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF009A44),
              secondary: const Color(0xFFFEDD00),
              brightness: Brightness.dark,
            ),
          ),
          themeMode: themeProvider.themeMode,
          debugShowCheckedModeBanner: false,
          initialRoute: '/',
          routes: {
            '/': (context) => const SplashScreen(),
            '/auth': (context) => const AuthScreen(),
            '/home': (context) => const HomeScreen(),
          },
        );
      },
    );
  }
}