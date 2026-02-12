class OrderModel {
  final String id;
  final String buyerId;
  final String sellerId;
  final List<OrderItem> items;
  final double totalAmount;
  final String currency;
  final String status; // 'pending', 'confirmed', 'shipped', 'delivered', 'cancelled'
  final String paymentStatus; // 'pending', 'paid', 'failed', 'refunded'
  final String paymentMethod; // 'telebirr', 'cbe_birr', 'cash'
  final String? shippingAddress;
  final String? deliveryNotes;
  final DateTime createdAt;
  final DateTime? confirmedAt;
  final DateTime? shippedAt;
  final DateTime? deliveredAt;
  final bool escrowReleased;
  final DateTime? escrowReleasedAt;
  final String? trackingNumber;

  OrderModel({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.items,
    required this.totalAmount,
    this.currency = 'ETB',
    required this.status,
    required this.paymentStatus,
    required this.paymentMethod,
    this.shippingAddress,
    this.deliveryNotes,
    required this.createdAt,
    this.confirmedAt,
    this.shippedAt,
    this.deliveredAt,
    this.escrowReleased = false,
    this.escrowReleasedAt,
    this.trackingNumber,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    if (json['items'] != null) {
      items = (json['items'] as List)
          .map((item) => OrderItem.fromJson(item))
          .toList();
    }

    return OrderModel(
      id: json['id'] ?? '',
      buyerId: json['buyer_id'] ?? '',
      sellerId: json['seller_id'] ?? '',
      items: items,
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'ETB',
      status: json['status'] ?? 'pending',
      paymentStatus: json['payment_status'] ?? 'pending',
      paymentMethod: json['payment_method'] ?? 'cash',
      shippingAddress: json['shipping_address'],
      deliveryNotes: json['delivery_notes'],
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      confirmedAt: json['confirmed_at'] != null 
          ? DateTime.parse(json['confirmed_at']) 
          : null,
      shippedAt: json['shipped_at'] != null 
          ? DateTime.parse(json['shipped_at']) 
          : null,
      deliveredAt: json['delivered_at'] != null 
          ? DateTime.parse(json['delivered_at']) 
          : null,
      escrowReleased: json['escrow_released'] ?? false,
      escrowReleasedAt: json['escrow_released_at'] != null 
          ? DateTime.parse(json['escrow_released_at']) 
          : null,
      trackingNumber: json['tracking_number'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'buyer_id': buyerId,
      'seller_id': sellerId,
      'items': items.map((item) => item.toJson()).toList(),
      'total_amount': totalAmount,
      'currency': currency,
      'status': status,
      'payment_status': paymentStatus,
      'payment_method': paymentMethod,
      'shipping_address': shippingAddress,
      'delivery_notes': deliveryNotes,
      'created_at': createdAt.toIso8601String(),
      'confirmed_at': confirmedAt?.toIso8601String(),
      'shipped_at': shippedAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'escrow_released': escrowReleased,
      'escrow_released_at': escrowReleasedAt?.toIso8601String(),
      'tracking_number': trackingNumber,
    };
  }

  OrderModel copyWith({
    String? id,
    String? buyerId,
    String? sellerId,
    List<OrderItem>? items,
    double? totalAmount,
    String? currency,
    String? status,
    String? paymentStatus,
    String? paymentMethod,
    String? shippingAddress,
    String? deliveryNotes,
    DateTime? createdAt,
    DateTime? confirmedAt,
    DateTime? shippedAt,
    DateTime? deliveredAt,
    bool? escrowReleased,
    DateTime? escrowReleasedAt,
    String? trackingNumber,
  }) {
    return OrderModel(
      id: id ?? this.id,
      buyerId: buyerId ?? this.buyerId,
      sellerId: sellerId ?? this.sellerId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      createdAt: createdAt ?? this.createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      shippedAt: shippedAt ?? this.shippedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      escrowReleased: escrowReleased ?? this.escrowReleased,
      escrowReleasedAt: escrowReleasedAt ?? this.escrowReleasedAt,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }

  String get formattedTotal {
    return 'ETB ${totalAmount.toStringAsFixed(2)}';
  }
}

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;
  final String? productImage;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.productImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'] ?? '',
      productName: json['product_name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      productImage: json['product_image'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'product_image': productImage,
    };
  }

  double get total => price * quantity;
}