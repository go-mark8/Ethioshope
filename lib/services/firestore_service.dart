import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/order_model.dart';
import '../models/message_model.dart';
import '../models/review_model.dart';
import '../models/notification_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _productsCollection =>
      _firestore.collection('products');
  CollectionReference get _ordersCollection => _firestore.collection('orders');
  CollectionReference get _messagesCollection =>
      _firestore.collection('messages');
  CollectionReference get _reviewsCollection => _firestore.collection('reviews');
  CollectionReference get _notificationsCollection =>
      _firestore.collection('notifications');

  // ===== USER OPERATIONS =====
  
  // Get user by ID
  Future<UserModel?> getUser(String userId) async {
    try {
      DocumentSnapshot doc = await _usersCollection.doc(userId).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get user: ${e.toString()}');
    }
  }

  // Get all users (admin only)
  Future<List<UserModel>> getAllUsers() async {
    try {
      QuerySnapshot snapshot = await _usersCollection.get();
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Failed to get users: ${e.toString()}');
    }
  }

  // Update user
  Future<void> updateUser(UserModel user) async {
    try {
      await _usersCollection.doc(user.id).update(user.toJson());
    } catch (e) {
      throw Exception('Failed to update user: ${e.toString()}');
    }
  }

  // ===== PRODUCT OPERATIONS =====
  
  // Add product
  Future<void> addProduct(ProductModel product) async {
    try {
      await _productsCollection.doc(product.id).set(product.toJson());
    } catch (e) {
      throw Exception('Failed to add product: ${e.toString()}');
    }
  }

  // Get product by ID
  Future<ProductModel?> getProduct(String productId) async {
    try {
      DocumentSnapshot doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        return ProductModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product: ${e.toString()}');
    }
  }

  // Get all products
  Stream<List<ProductModel>> getProducts() {
    return _productsCollection
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get products by category
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _productsCollection
        .where('category', isEqualTo: category)
        .where('status', isEqualTo: 'available')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get products by seller
  Stream<List<ProductModel>> getSellerProducts(String sellerId) {
    return _productsCollection
        .where('seller_id', isEqualTo: sellerId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get products by location
  Stream<List<ProductModel>> getProductsByLocation(String location) {
    return _productsCollection
        .where('location', isEqualTo: location)
        .where('status', isEqualTo: 'available')
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Search products
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      QuerySnapshot snapshot = await _productsCollection
          .where('status', isEqualTo: 'available')
          .get();

      List<ProductModel> allProducts = snapshot.docs
          .map((doc) => ProductModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();

      // Simple text search (for production, use Algolia or Elasticsearch)
      return allProducts
          .where((product) =>
              product.title.toLowerCase().contains(query.toLowerCase()) ||
              product.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search products: ${e.toString()}');
    }
  }

  // Update product
  Future<void> updateProduct(ProductModel product) async {
    try {
      await _productsCollection.doc(product.id).update(product.toJson());
    } catch (e) {
      throw Exception('Failed to update product: ${e.toString()}');
    }
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    try {
      await _productsCollection.doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: ${e.toString()}');
    }
  }

  // ===== ORDER OPERATIONS =====
  
  // Create order
  Future<void> createOrder(OrderModel order) async {
    try {
      await _ordersCollection.doc(order.id).set(order.toJson());
    } catch (e) {
      throw Exception('Failed to create order: ${e.toString()}');
    }
  }

  // Get order by ID
  Future<OrderModel?> getOrder(String orderId) async {
    try {
      DocumentSnapshot doc = await _ordersCollection.doc(orderId).get();
      if (doc.exists) {
        return OrderModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get order: ${e.toString()}');
    }
  }

  // Get orders by buyer
  Stream<List<OrderModel>> getBuyerOrders(String buyerId) {
    return _ordersCollection
        .where('buyer_id', isEqualTo: buyerId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get orders by seller
  Stream<List<OrderModel>> getSellerOrders(String sellerId) {
    return _ordersCollection
        .where('seller_id', isEqualTo: sellerId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Update order status
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      Map<String, dynamic> updateData = {'status': status};

      // Add timestamp based on status
      switch (status) {
        case 'confirmed':
          updateData['confirmed_at'] = FieldValue.serverTimestamp();
          break;
        case 'shipped':
          updateData['shipped_at'] = FieldValue.serverTimestamp();
          break;
        case 'delivered':
          updateData['delivered_at'] = FieldValue.serverTimestamp();
          break;
      }

      await _ordersCollection.doc(orderId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update order status: ${e.toString()}');
    }
  }

  // Release escrow payment
  Future<void> releaseEscrowPayment(String orderId) async {
    try {
      await _ordersCollection.doc(orderId).update({
        'escrow_released': true,
        'escrow_released_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to release escrow: ${e.toString()}');
    }
  }

  // ===== MESSAGE OPERATIONS =====
  
  // Send message
  Future<void> sendMessage(MessageModel message) async {
    try {
      await _messagesCollection.doc(message.id).set(message.toJson());
    } catch (e) {
      throw Exception('Failed to send message: ${e.toString()}');
    }
  }

  // Get conversation between two users
  Stream<List<MessageModel>> getConversation(String userId1, String userId2) {
    return _messagesCollection
        .where('sender_id', whereIn: [userId1, userId2])
        .where('receiver_id', whereIn: [userId1, userId2])
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get user conversations
  Future<List<Map<String, dynamic>>> getUserConversations(String userId) async {
    try {
      // Get all messages involving the user
      QuerySnapshot sentSnapshot = await _messagesCollection
          .where('sender_id', isEqualTo: userId)
          .get();

      QuerySnapshot receivedSnapshot = await _messagesCollection
          .where('receiver_id', isEqualTo: userId)
          .get();

      Set<String> conversationPartners = {};
      
      for (var doc in sentSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        conversationPartners.add(data['receiver_id'] as String);
      }
      
      for (var doc in receivedSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        conversationPartners.add(data['sender_id'] as String);
      }

      // Get user details for each conversation partner
      List<Map<String, dynamic>> conversations = [];
      
      for (String partnerId in conversationPartners) {
        UserModel? partner = await getUser(partnerId);
        if (partner != null) {
          conversations.add({
            'user': partner,
            'lastMessage': await _getLastMessage(userId, partnerId),
          });
        }
      }

      return conversations;
    } catch (e) {
      throw Exception('Failed to get conversations: ${e.toString()}');
    }
  }

  Future<MessageModel?> _getLastMessage(String userId1, String userId2) async {
    QuerySnapshot snapshot = await _messagesCollection
        .where('sender_id', whereIn: [userId1, userId2])
        .where('receiver_id', whereIn: [userId1, userId2])
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isNotEmpty) {
      return MessageModel.fromJson(
          snapshot.docs.first.data() as Map<String, dynamic>);
    }
    return null;
  }

  // Mark messages as read
  Future<void> markMessagesAsRead(String senderId, String receiverId) async {
    try {
      QuerySnapshot snapshot = await _messagesCollection
          .where('sender_id', isEqualTo: senderId)
          .where('receiver_id', isEqualTo: receiverId)
          .where('is_read', isEqualTo: false)
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({'is_read': true});
      }
    } catch (e) {
      throw Exception('Failed to mark messages as read: ${e.toString()}');
    }
  }

  // ===== REVIEW OPERATIONS =====
  
  // Add review
  Future<void> addReview(ReviewModel review) async {
    try {
      await _reviewsCollection.doc(review.id).set(review.toJson());
    } catch (e) {
      throw Exception('Failed to add review: ${e.toString()}');
    }
  }

  // Get reviews by order
  Stream<List<ReviewModel>> getOrderReviews(String orderId) {
    return _reviewsCollection
        .where('order_id', isEqualTo: orderId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Get reviews by reviewer
  Stream<List<ReviewModel>> getUserReviews(String userId) {
    return _reviewsCollection
        .where('reviewer_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ReviewModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // ===== NOTIFICATION OPERATIONS =====
  
  // Add notification
  Future<void> addNotification(NotificationModel notification) async {
    try {
      await _notificationsCollection.doc(notification.id).set(notification.toJson());
    } catch (e) {
      throw Exception('Failed to add notification: ${e.toString()}');
    }
  }

  // Get user notifications
  Stream<List<NotificationModel>> getUserNotifications(String userId) {
    return _notificationsCollection
        .where('recipient_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => NotificationModel.fromJson(doc.data() as Map<String, dynamic>))
            .toList());
  }

  // Mark notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).update({
        'status': 'read',
        'read_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark notification as read: ${e.toString()}');
    }
  }

  // Mark all notifications as read
  Future<void> markAllNotificationsAsRead(String userId) async {
    try {
      QuerySnapshot snapshot = await _notificationsCollection
          .where('recipient_id', isEqualTo: userId)
          .where('status', isEqualTo: 'unread')
          .get();

      for (var doc in snapshot.docs) {
        await doc.reference.update({
          'status': 'read',
          'read_at': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      throw Exception('Failed to mark all notifications as read: ${e.toString()}');
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationsCollection.doc(notificationId).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: ${e.toString()}');
    }
  }
}