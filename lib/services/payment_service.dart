import 'package:cloud_functions/cloud_functions.dart';
import '../models/order_model.dart';

class PaymentService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Process payment with Telebirr (Mock)
  Future<Map<String, dynamic>> processTelebirrPayment({
    required String orderId,
    required double amount,
    required String phoneNumber,
    required String userId,
  }) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('processTelebirrPayment');
      
      final result = await callable.call(<String, dynamic>{
        'order_id': orderId,
        'amount': amount,
        'phone_number': phoneNumber,
        'user_id': userId,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Telebirr payment failed: ${e.toString()}');
    }
  }

  // Process payment with CBE Birr (Mock)
  Future<Map<String, dynamic>> processCBEBirrPayment({
    required String orderId,
    required double amount,
    required String accountNumber,
    required String userId,
  }) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('processCBEBirrPayment');
      
      final result = await callable.call(<String, dynamic>{
        'order_id': orderId,
        'amount': amount,
        'account_number': accountNumber,
        'user_id': userId,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('CBE Birr payment failed: ${e.toString()}');
    }
  }

  // Verify payment status
  Future<Map<String, dynamic>> verifyPaymentStatus({
    required String orderId,
    required String paymentMethod,
  }) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('verifyPaymentStatus');
      
      final result = await callable.call(<String, dynamic>{
        'order_id': orderId,
        'payment_method': paymentMethod,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Payment verification failed: ${e.toString()}');
    }
  }

  // Request refund
  Future<Map<String, dynamic>> requestRefund({
    required String orderId,
    required String reason,
  }) async {
    try {
      HttpsCallable callable = _functions.httpsCallable('requestRefund');
      
      final result = await callable.call(<String, dynamic>{
        'order_id': orderId,
        'reason': reason,
      });

      return Map<String, dynamic>.from(result.data);
    } catch (e) {
      throw Exception('Refund request failed: ${e.toString()}');
    }
  }

  // Get payment methods
  List<PaymentMethod> getAvailablePaymentMethods() {
    return [
      PaymentMethod.telebirr,
      PaymentMethod.cbeBirr,
      PaymentMethod.cashOnDelivery,
    ];
  }

  // Format amount for display
  String formatAmount(double amount) {
    return 'ETB ${amount.toStringAsFixed(2)}';
  }

  // Validate phone number for payment
  bool validatePhoneNumber(String phoneNumber) {
    // Ethiopian phone number format: +2519xxxxxxxx or 09xxxxxxxx
    final regex = RegExp(r'^(\+251|0)?9[0-9]{8}$');
    return regex.hasMatch(phoneNumber);
  }

  // Validate account number
  bool validateAccountNumber(String accountNumber) {
    // CBE account number format (13 digits)
    final regex = RegExp(r'^[0-9]{13}$');
    return regex.hasMatch(accountNumber);
  }
}

enum PaymentMethod {
  telebirr,
  cbeBirr,
  cashOnDelivery,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.telebirr:
        return 'Telebirr';
      case PaymentMethod.cbeBirr:
        return 'CBE Birr';
      case PaymentMethod.cashOnDelivery:
        return 'Cash on Delivery';
    }
  }

  String get icon {
    switch (this) {
      case PaymentMethod.telebirr:
        return '📱';
      case PaymentMethod.cbeBirr:
        return '🏦';
      case PaymentMethod.cashOnDelivery:
        return '💵';
    }
  }
}