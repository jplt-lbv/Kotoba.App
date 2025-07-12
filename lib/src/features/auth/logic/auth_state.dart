part of 'auth_controller.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  
  AuthAuthenticated({required this.user});
  
  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final ApiError error;
  
  AuthError({required this.error});
  
  @override
  List<Object?> get props => [error];
}