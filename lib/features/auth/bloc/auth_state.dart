
// Garantir herança do Equatable:
import 'package:flutter/foundation.dart';
import 'package:freela_app/core/model/user_model.dart';

@immutable
abstract class AuthState {
  const AuthState();
  List<Object> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {}

class PasswordResetSuccess extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}