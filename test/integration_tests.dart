import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:ethioshop/main.dart';
import 'package:firebase_core/firebase_core.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('EthioShop Integration Tests', () {
    testWidgets('Full app flow test', (WidgetTester tester) async {
      // Initialize Firebase
      await Firebase.initializeApp();

      // Build and launch the app
      await tester.pumpWidget(const EthioShopApp());
      await tester.pumpAndSettle();

      // Verify splash screen
      expect(find.text('EthioShop'), findsOneWidget);
      
      // Wait for splash to complete
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Should be on login screen
      expect(find.text('Welcome to EthioShop'), findsOneWidget);
    });

    testWidgets('Navigation flow test', (WidgetTester tester) async {
      await Firebase.initializeApp();

      await tester.pumpWidget(const EthioShopApp());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to register screen
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Join EthioShop'), findsOneWidget);
    });

    testWidgets('Form validation test', (WidgetTester tester) async {
      await Firebase.initializeApp();

      await tester.pumpWidget(const EthioShopApp());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to register
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Try to submit empty form
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Please enter your name'), findsOneWidget);
    });

    testWidgets('Search functionality test', (WidgetTester tester) async {
      await Firebase.initializeApp();

      await tester.pumpWidget(const EthioShopApp());
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();

      // Navigate to home (simulated login)
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Email'),
        'test@example.com',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Password'),
        'password123',
      );
      await tester.pumpAndSettle();
    });
  });
}