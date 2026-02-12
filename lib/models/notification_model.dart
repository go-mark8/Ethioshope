class NotificationModel {
  final String id;
  final String recipientId;
  final NotificationType type;
  final String title;
  final String body;
  final String? relatedId; // product_id, order_id, message_id, etc.
  final NotificationStatus status;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.recipientId,
    required this.type,
    required this.title,
    required this.body,
    this.relatedId,
    this.status = NotificationStatus.unread,
    required this.createdAt,
    this.readAt,
    this.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      recipientId: json['recipient_id'] ?? '',
      type: NotificationType.values.firstWhere(
        (e) => e.toString() == 'NotificationType.${json['type'] ?? 'info'}',
        orElse: () => NotificationType.info,
      ),
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      relatedId: json['related_id'],
      status: NotificationStatus.values.firstWhere(
        (e) => e.toString() == 'NotificationStatus.${json['status'] ?? 'unread'}',
        orElse: () => NotificationStatus.unread,
      ),
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at']) 
          : null,
      data: json['data'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipient_id': recipientId,
      'type': type.toString().split('.').last,
      'title': title,
      'body': body,
      'related_id': relatedId,
      'status': status.toString().split('.').last,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
      'data': data,
    };
  }

  NotificationModel copyWith({
    String? id,
    String? recipientId,
    NotificationType? type,
    String? title,
    String? body,
    String? relatedId,
    NotificationStatus? status,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      relatedId: relatedId ?? this.relatedId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
    );
  }

  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
    }
  }

  bool get isRead => status == NotificationStatus.read;
}

enum NotificationType {
  order,
  message,
  product,
  system,
  promotion,
  review,
  payment,
}

enum NotificationStatus {
  unread,
  read,
  archived,
}