import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ethioshop/main.dart';
import 'package:ethioshop/screens/login_screen.dart';
import 'package:ethioshop/screens/product_list_screen.dart';
import 'package:ethioshop/widgets/custom_button.dart';
import 'package:ethioshop/widgets/product_card.dart';
import 'package:ethioshop/models/product_model.dart';

void main() {
  group('App Widget Tests', () {
    testWidgets('App loads splash screen', (WidgetTester tester) async {
      await tester.pumpWidget(const EthioShopApp());
      expect(find.text('EthioShop'), findsOneWidget);
    });
  });

  group('Custom Button Widget Tests', () {
    testWidgets('CustomButton displays text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('CustomButton shows loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              isLoading: true,
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('CustomButton is disabled when loading', (WidgetTester tester) async {
      bool buttonPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomButton(
              text: 'Test Button',
              isLoading: true,
              onPressed: () {
                buttonPressed = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(buttonPressed, false);
    });
  });

  group('Product Card Widget Tests', () {
    testWidgets('ProductCard displays product information', (WidgetTester tester) async {
      final product = ProductModel(
        id: '1',
        sellerId: 'seller1',
        title: 'Test Product',
        description: 'Test Description',
        images: ['https://example.com/image.jpg'],
        category: 'Electronics',
        price: 1000,
        location: 'Addis Ababa',
        createdAt: DateTime.now(),
        condition: 'new',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: product,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Product'), findsOneWidget);
      expect(find.text('ETB 1,000.00'), findsOneWidget);
      expect(find.text('Addis Ababa'), findsOneWidget);
    });

    testWidgets('ProductCard shows condition badge', (WidgetTester tester) async {
      final product = ProductModel(
        id: '1',
        sellerId: 'seller1',
        title: 'Test Product',
        description: 'Test Description',
        images: ['https://example.com/image.jpg'],
        category: 'Electronics',
        price: 1000,
        location: 'Addis Ababa',
        createdAt: DateTime.now(),
        condition: 'new',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ProductCard(
              product: product,
              onTap: () {},
            ),
          ),
        ),
      );

      expect(find.text('NEW'), findsOneWidget);
    });
  });

  group('Login Screen Tests', () {
    testWidgets('LoginScreen has email field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      expect(find.byType(TextFormField), findsWidgets);
      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('LoginScreen has password field', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('LoginScreen has sign in button', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const LoginScreen(),
        ),
      );

      expect(find.text('Sign In'), findsOneWidget);
    });
  });

  group('Product List Screen Tests', () {
    testWidgets('ProductListScreen has search bar', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: const ProductListScreen(),
        ),
      );

      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Search products...'), findsOneWidget);
    });
  });
}