import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required String id,
    required String email,
    required String firstName,
    required String lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    UserRole role = UserRole.user,
    bool isEmailVerified = false,
    bool isPhoneVerified = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
  }) : super(
    id: id,
    email: email,
    firstName: firstName,
    lastName: lastName,
    phoneNumber: phoneNumber,
    dateOfBirth: dateOfBirth,
    role: role,
    isEmailVerified: isEmailVerified,
    isPhoneVerified: isPhoneVerified,
    createdAt: createdAt,
    updatedAt: updatedAt,
    profileImageUrl: profileImageUrl,
    preferences: preferences,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String,
      phoneNumber: json['phone_number'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      role: UserRole.values.firstWhere(
        (e) => e.toString().split('.').last == json['role'],
        orElse: () => UserRole.user,
      ),
      isEmailVerified: json['is_email_verified'] as bool? ?? false,
      isPhoneVerified: json['is_phone_verified'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      profileImageUrl: json['profile_image_url'] as String?,
      preferences: json['preferences'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'role': role.toString().split('.').last,
      'is_email_verified': isEmailVerified,
      'is_phone_verified': isPhoneVerified,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profile_image_url': profileImageUrl,
      'preferences': preferences,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    DateTime? dateOfBirth,
    UserRole? role,
    bool? isEmailVerified,
    bool? isPhoneVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? profileImageUrl,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      preferences: preferences ?? this.preferences,
    );
  }
}