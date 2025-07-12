import 'package:equatable/equatable.dart';

class AuthCredentials extends Equatable {
  final String email;
  final String password;

  const AuthCredentials({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthToken extends Equatable {
  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  const AuthToken({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [accessToken, refreshToken, expiresAt];
}

class User extends Equatable {
  final String id;
  final String email;
  final String name;
  
  const User({required this.id, required this.email, required this.name});
  
  @override
  List<Object?> get props => [id, email, name];
}