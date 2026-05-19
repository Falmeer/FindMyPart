class UserModel {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final bool phoneVerified;
  final bool mustChangePassword;
  final String role;
  final String? avatar;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.phoneVerified = false,
    this.mustChangePassword = false,
    required this.role,
    this.avatar,
    this.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'] as int,
        name: json['name'] as String,
        email: json['email'] as String,
        phone: json['phone'] as String?,
        phoneVerified: json['phone_verified'] as bool? ?? false,
        mustChangePassword: json['must_change_password'] as bool? ?? false,
        role: json['role'] as String? ?? 'customer',
        avatar: json['avatar'] as String?,
        token: json['token'] as String?,
      );

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    bool? phoneVerified,
    bool? mustChangePassword,
    String? role,
    String? avatar,
    String? token,
  }) => UserModel(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        phone: phone ?? this.phone,
        phoneVerified: phoneVerified ?? this.phoneVerified,
        mustChangePassword: mustChangePassword ?? this.mustChangePassword,
        role: role ?? this.role,
        avatar: avatar ?? this.avatar,
        token: token ?? this.token,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'phone_verified': phoneVerified,
        'must_change_password': mustChangePassword,
        'role': role,
        'avatar': avatar,
      };

  bool get isGarage => role == 'garage';
  bool get isYardOwner => role == 'yard_owner';
  bool get isCustomer => role == 'customer';
  bool get isAdmin => role == 'admin';
}
