import 'package:flutter/material.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
  List<Object> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  const LoginEvent({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class SignUpEvent extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String telefone;

  const SignUpEvent({
    required this.name,
    required this.email,
    required this.password,
    required this.telefone
  });

  @override
  List<Object> get props => [name, email, password, telefone];
}

class LogoutEvent extends AuthEvent {}

class ResetPasswordEvent extends AuthEvent {
  final String email;

  const ResetPasswordEvent({required this.email});

  @override
  List<Object> get props => [email];
}