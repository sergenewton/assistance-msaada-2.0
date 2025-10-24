import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final DateTime createdAt;
  final bool isVerified;

  const User({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    required this.createdAt,
    required this.isVerified,
  });

  @override
  List<Object?> get props => [id, email, name, phone, createdAt, isVerified];
}