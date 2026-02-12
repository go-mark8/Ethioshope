class ReviewModel {
  final String id;
  final String orderId;
  final String reviewerId;
  final String reviewerName;
  final String? reviewerImage;
  final int rating; // 1-5 stars
  final String comment;
  final DateTime createdAt;
  final List<String>? images;
  final bool verifiedPurchase;

  ReviewModel({
    required this.id,
    required this.orderId,
    required this.reviewerId,
    required this.reviewerName,
    this.reviewerImage,
    required this.rating,
    required this.comment,
    required this.createdAt,
    this.images,
    this.verifiedPurchase = false,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] ?? '',
      orderId: json['order_id'] ?? '',
      reviewerId: json['reviewer_id'] ?? '',
      reviewerName: json['reviewer_name'] ?? '',
      reviewerImage: json['reviewer_image'],
      rating: json['rating'] ?? 5,
      comment: json['comment'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      images: json['images'] != null 
          ? List<String>.from(json['images']) 
          : null,
      verifiedPurchase: json['verified_purchase'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_id': orderId,
      'reviewer_id': reviewerId,
      'reviewer_name': reviewerName,
      'reviewer_image': reviewerImage,
      'rating': rating,
      'comment': comment,
      'created_at': createdAt.toIso8601String(),
      'images': images,
      'verified_purchase': verifiedPurchase,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? orderId,
    String? reviewerId,
    String? reviewerName,
    String? reviewerImage,
    int? rating,
    String? comment,
    DateTime? createdAt,
    List<String>? images,
    bool? verifiedPurchase,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerImage: reviewerImage ?? this.reviewerImage,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      images: images ?? this.images,
      verifiedPurchase: verifiedPurchase ?? this.verifiedPurchase,
    );
  }

  String get formattedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }

  List<String> get starDisplay {
    return List.generate(5, (index) {
      if (index < rating) return 'filled';
      return 'empty';
    });
  }
}