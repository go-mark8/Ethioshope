import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';
import 'firestore_service.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Initialize notifications
  Future<void> initialize() async {
    // Request permission for iOS
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else {
      print('User declined or has not accepted permission');
    }

    // Initialize local notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _localNotifications.initialize(initializationSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Handle message when app opens from notification
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Get initial message if app was opened from notification
    RemoteMessage? initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  // Get FCM token
  Future<String?> getFCMToken() async {
    try {
      String? token = await _firebaseMessaging.getToken();
      return token;
    } catch (e) {
      print('Failed to get FCM token: $e');
      return null;
    }
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
    } catch (e) {
      print('Failed to subscribe to topic: $e');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
    } catch (e) {
      print('Failed to unsubscribe from topic: $e');
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
      _showLocalNotification(message);
    }
  }

  // Handle message opened app
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('A new onMessageOpenedApp event was published!');
    // Navigate to relevant screen based on message data
  }

  // Show local notification
  Future<void> _showLocalNotification(RemoteMessage message) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'ethioshop_channel',
      'EthioShop Notifications',
      channelDescription: 'Notifications from EthioShop',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'EthioShop',
      message.notification?.body ?? '',
      platformChannelSpecifics,
      payload: message.data.toString(),
    );
  }

  // Create notification in Firestore
  Future<void> createNotification({
    required String recipientId,
    required NotificationType type,
    required String title,
    required String body,
    String? relatedId,
    Map<String, dynamic>? data,
  }) async {
    try {
      String notificationId =
          FirebaseFirestore.instance.collection('notifications').doc().id;

      NotificationModel notification = NotificationModel(
        id: notificationId,
        recipientId: recipientId,
        type: type,
        title: title,
        body: body,
        relatedId: relatedId,
        status: NotificationStatus.unread,
        createdAt: DateTime.now(),
        data: data,
      );

      await _firestoreService.addNotification(notification);

      // Send push notification
      await _sendPushNotification(notification);
    } catch (e) {
      print('Failed to create notification: $e');
    }
  }

  // Send push notification
  Future<void> _sendPushNotification(NotificationModel notification) async {
    try {
      // This would typically be done via Cloud Functions
      // For now, we'll just create the Firestore notification
      print('Push notification sent: ${notification.title}');
    } catch (e) {
      print('Failed to send push notification: $e');
    }
  }

  // Notification helpers for specific events
  Future<void> notifyOrderCreated({
    required String sellerId,
    required String orderId,
    required String orderTotal,
  }) async {
    await createNotification(
      recipientId: sellerId,
      type: NotificationType.order,
      title: 'New Order Received',
      body: 'You have a new order worth $orderTotal',
      relatedId: orderId,
      data: {'order_id': orderId},
    );
  }

  Future<void> notifyOrderStatusChanged({
    required String buyerId,
    required String orderId,
    required String status,
  }) async {
    await createNotification(
      recipientId: buyerId,
      type: NotificationType.order,
      title: 'Order Status Updated',
      body: 'Your order status is now: $status',
      relatedId: orderId,
      data: {'order_id': orderId, 'status': status},
    );
  }

  Future<void> notifyNewMessage({
    required String receiverId,
    required String senderName,
    required String messageId,
  }) async {
    await createNotification(
      recipientId: receiverId,
      type: NotificationType.message,
      title: 'New Message',
      body: 'New message from $senderName',
      relatedId: messageId,
      data: {'message_id': messageId},
    );
  }

  Future<void> notifyProductLiked({
    required String sellerId,
    required String productName,
    required String productId,
  }) async {
    await createNotification(
      recipientId: sellerId,
      type: NotificationType.product,
      title: 'Product Liked',
      body: 'Someone liked your product: $productName',
      relatedId: productId,
      data: {'product_id': productId},
    );
  }

  Future<void> notifyReviewReceived({
    required String sellerId,
    required int rating,
    required String orderId,
  }) async {
    await createNotification(
      recipientId: sellerId,
      type: NotificationType.review,
      title: 'New Review',
      body: 'You received a $rating-star review',
      relatedId: orderId,
      data: {'order_id': orderId, 'rating': rating},
    );
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message: ${message.messageId}');
}