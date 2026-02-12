class ProductModel {
  final String id;
  final String sellerId;
  final String title;
  final String description;
  final List<String> images;
  final String category;
  final double price;
  final String currency; // Default 'ETB'
  final String condition; // 'new', 'like_new', 'used'
  final String status; // 'available', 'sold', 'pending'
  final String location;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int? views;
  final double? rating;
  final int? reviewCount;

  ProductModel({
    required this.id,
    required this.sellerId,
    required this.title,
    required this.description,
    required this.images,
    required this.category,
    required this.price,
    this.currency = 'ETB',
    required this.condition,
    this.status = 'available',
    required this.location,
    required this.createdAt,
    this.updatedAt,
    this.views,
    this.rating,
    this.reviewCount,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      sellerId: json['seller_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      category: json['category'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'ETB',
      condition: json['condition'] ?? 'new',
      status: json['status'] ?? 'available',
      location: json['location'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      views: json['views'],
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'seller_id': sellerId,
      'title': title,
      'description': description,
      'images': images,
      'category': category,
      'price': price,
      'currency': currency,
      'condition': condition,
      'status': status,
      'location': location,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'views': views,
      'rating': rating,
      'review_count': reviewCount,
    };
  }

  ProductModel copyWith({
    String? id,
    String? sellerId,
    String? title,
    String? description,
    List<String>? images,
    String? category,
    double? price,
    String? currency,
    String? condition,
    String? status,
    String? location,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? views,
    double? rating,
    int? reviewCount,
  }) {
    return ProductModel(
      id: id ?? this.id,
      sellerId: sellerId ?? this.sellerId,
      title: title ?? this.title,
      description: description ?? this.description,
      images: images ?? this.images,
      category: category ?? this.category,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      condition: condition ?? this.condition,
      status: status ?? this.status,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      views: views ?? this.views,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
    );
  }

  String get formattedPrice {
    return 'ETB ${price.toStringAsFixed(2)}';
  }
}