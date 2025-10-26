import 'package:equatable/equatable.dart';

enum UserRole {
  user,
  admin,
  moderator,
  counselor,
}

class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final UserRole role;
  final bool isEmailVerified;
  final bool isPhoneVerified;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? profileImageUrl;
  final Map<String, dynamic>? preferences;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.phoneNumber,
    this.dateOfBirth,
    this.role = UserRole.user,
    this.isEmailVerified = false,
    this.isPhoneVerified = false,
    this.createdAt,
    this.updatedAt,
    this.profileImageUrl,
    this.preferences,
  });

  @override
  List<Object?> get props => [
        id,
        email,
        firstName,
        lastName,
        phoneNumber,
        dateOfBirth,
        role,
        isEmailVerified,
        isPhoneVerified,
        createdAt,
        updatedAt,
        profileImageUrl,
        preferences,
      ];

  /// Get full name
  String get fullName => '$firstName $lastName';

  /// Get initials
  String get initials {
    final firstInitial = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final lastInitial = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$firstInitial$lastInitial';
  }

  /// Get display name for user role
  String get roleDisplayName {
    switch (role) {
      case UserRole.user:
        return 'Utilisateur';
      case UserRole.admin:
        return 'Administrateur';
      case UserRole.moderator:
        return 'Modérateur';
      case UserRole.counselor:
        return 'Conseiller';
    }
  }

  /// Check if user is verified
  bool get isVerified => isEmailVerified;

  /// Check if user is an admin
  bool get isAdmin => role == UserRole.admin;

  /// Check if user is a moderator or admin
  bool get isModerator => role == UserRole.moderator || role == UserRole.admin;

  /// Check if user is a counselor
  bool get isCounselor => role == UserRole.counselor;

  /// Get age from date of birth
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    final age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      return age - 1;
    }
    return age;
  }

  /// Check if profile is complete
  bool get isProfileComplete {
    return firstName.isNotEmpty &&
           lastName.isNotEmpty &&
           email.isNotEmpty &&
           isEmailVerified;
  }

  /// Get preference value
  T? getPreference<T>(String key, [T? defaultValue]) {
    if (preferences == null) return defaultValue;
    return preferences![key] as T? ?? defaultValue;
  }

  User copyWith({
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
    return User(
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