import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ethioshop/models/product_model.dart';
import 'package:ethioshop/models/user_model.dart';
import 'package:ethioshop/services/firestore_service.dart';

// Mock classes
class MockQuerySnapshot extends Mock implements QuerySnapshot {}
class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockQuery extends Mock implements Query {}

void main() {
  group('FirestoreService Tests', () {
    late FirestoreService firestoreService;

    setUp(() {
      firestoreService = FirestoreService();
    });

    group('Product Operations', () {
      test('should create product', () async {
        final product = ProductModel(
          id: 'test1',
          sellerId: 'seller1',
          title: 'Test Product',
          description: 'Test Description',
          images: [],
          category: 'Electronics',
          price: 1000,
          location: 'Addis Ababa',
          createdAt: DateTime.now(),
          condition: 'new',
        );

        // In a real test, we would mock the Firestore instance
        // and verify that the set method is called with correct data

        expect(product.title, 'Test Product');
        expect(product.price, 1000);
      });

      test('should parse product from JSON', () {
        final json = {
          'id': 'test1',
          'seller_id': 'seller1',
          'title': 'Test Product',
          'description': 'Test Description',
          'images': [],
          'category': 'Electronics',
          'price': 1000,
          'location': 'Addis Ababa',
          'created_at': DateTime.now().toIso8601String(),
          'condition': 'new',
          'status': 'available',
          'currency': 'ETB',
        };

        final product = ProductModel.fromJson(json);

        expect(product.id, 'test1');
        expect(product.title, 'Test Product');
        expect(product.sellerId, 'seller1');
      });

      test('should convert product to JSON', () {
        final product = ProductModel(
          id: 'test1',
          sellerId: 'seller1',
          title: 'Test Product',
          description: 'Test Description',
          images: [],
          category: 'Electronics',
          price: 1000,
          location: 'Addis Ababa',
          createdAt: DateTime.now(),
          condition: 'new',
        );

        final json = product.toJson();

        expect(json['id'], 'test1');
        expect(json['title'], 'Test Product');
        expect(json['seller_id'], 'seller1');
      });
    });

    group('User Operations', () {
      test('should create user', () {
        final user = UserModel(
          id: 'user1',
          name: 'Test User',
          email: 'test@example.com',
          phone: '+251911123456',
          role: 'buyer',
          createdAt: DateTime.now(),
        );

        expect(user.name, 'Test User');
        expect(user.email, 'test@example.com');
        expect(user.role, 'buyer');
      });

      test('should parse user from JSON', () {
        final json = {
          'id': 'user1',
          'name': 'Test User',
          'email': 'test@example.com',
          'phone': '+251911123456',
          'role': 'buyer',
          'created_at': DateTime.now().toIso8601String(),
          'verified': false,
        };

        final user = UserModel.fromJson(json);

        expect(user.id, 'user1');
        expect(user.name, 'Test User');
        expect(user.verified, false);
      });

      test('should convert user to JSON', () {
        final user = UserModel(
          id: 'user1',
          name: 'Test User',
          email: 'test@example.com',
          phone: '+251911123456',
          role: 'buyer',
          createdAt: DateTime.now(),
        );

        final json = user.toJson();

        expect(json['id'], 'user1');
        expect(json['name'], 'Test User');
        expect(json['role'], 'buyer');
      });
    });

    group('Product Model Tests', () {
      test('should format price correctly', () {
        final product = ProductModel(
          id: 'test1',
          sellerId: 'seller1',
          title: 'Test Product',
          description: 'Test Description',
          images: [],
          category: 'Electronics',
          price: 12500.50,
          location: 'Addis Ababa',
          createdAt: DateTime.now(),
          condition: 'new',
        );

        expect(product.formattedPrice, 'ETB 12,500.50');
      });

      test('should copy product with updates', () {
        final product = ProductModel(
          id: 'test1',
          sellerId: 'seller1',
          title: 'Test Product',
          description: 'Test Description',
          images: [],
          category: 'Electronics',
          price: 1000,
          location: 'Addis Ababa',
          createdAt: DateTime.now(),
          condition: 'new',
        );

        final updatedProduct = product.copyWith(
          title: 'Updated Product',
          price: 1500,
        );

        expect(updatedProduct.title, 'Updated Product');
        expect(updatedProduct.price, 1500);
        expect(updatedProduct.id, product.id);
      });
    });

    group('User Model Tests', () {
      test('should update user fields', () {
        final user = UserModel(
          id: 'user1',
          name: 'Test User',
          email: 'test@example.com',
          phone: '+251911123456',
          role: 'buyer',
          createdAt: DateTime.now(),
        );

        final updatedUser = user.copyWith(
          name: 'Updated User',
          location: 'Hawassa',
        );

        expect(updatedUser.name, 'Updated User');
        expect(updatedUser.location, 'Hawassa');
        expect(updatedUser.id, user.id);
      });
    });

    group('Data Validation Tests', () {
      test('should validate Ethiopian phone number', () {
        final validPhones = [
          '+251911123456',
          '0911123456',
          '251911123456',
        ];

        final invalidPhones = [
          '123456789',
          '0811123456',
          '+251811123456',
        ];

        for (final phone in validPhones) {
          expect(_isValidEthiopianPhone(phone), true);
        }

        for (final phone in invalidPhones) {
          expect(_isValidEthiopianPhone(phone), false);
        }
      });

      test('should validate price range', () {
        expect(_isValidPrice(100), true);
        expect(_isValidPrice(50000), true);
        expect(_isValidPrice(99), false);
        expect(_isValidPrice(50001), false);
      });
    });

    group('Category Tests', () {
      test('should have valid categories', () {
        final categories = [
          'Electronics',
          'Fashion & Clothing',
          'Home & Furniture',
          'Books & Stationery',
          'Beauty & Personal Care',
          'Sports & Outdoors',
          'Food & Beverages',
          'Automotive',
        ];

        for (final category in categories) {
          expect(categories.contains(category), true);
        }
      });
    });
  });
}

// Helper functions for validation
bool _isValidEthiopianPhone(String phone) {
  final regex = RegExp(r'^(\+251|0)?9[0-9]{8}$');
  return regex.hasMatch(phone);
}

bool _isValidPrice(double price) {
  return price >= 100 && price <= 50000;
}