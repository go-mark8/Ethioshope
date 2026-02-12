class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'buyer', 'seller', 'admin'
  final String? fcmToken;
  final bool verified;
  final DateTime createdAt;
  final String? profileImage;
  final String? location;
  final String? address;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.fcmToken,
    this.verified = false,
    required this.createdAt,
    this.profileImage,
    this.location,
    this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'buyer',
      fcmToken: json['fcm_token'],
      verified: json['verified'] ?? false,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      profileImage: json['profile_image'],
      location: json['location'],
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'fcm_token': fcmToken,
      'verified': verified,
      'created_at': createdAt.toIso8601String(),
      'profile_image': profileImage,
      'location': location,
      'address': address,
    };
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? fcmToken,
    bool? verified,
    DateTime? createdAt,
    String? profileImage,
    String? location,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      fcmToken: fcmToken ?? this.fcmToken,
      verified: verified ?? this.verified,
      createdAt: createdAt ?? this.createdAt,
      profileImage: profileImage ?? this.profileImage,
      location: location ?? this.location,
      address: address ?? this.address,
    );
  }
}