import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freela_app/core/model/user_model.dart';
import 'package:freela_app/features/auth/bloc/auth_event.dart';
import 'package:freela_app/features/auth/bloc/auth_state.dart';


class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthBloc() : super(AuthInitial()) {
    on<LoginEvent>(_login);
    on<SignUpEvent>(_signUp);
    on<LogoutEvent>(_logout);
    on<ResetPasswordEvent>(_resetPassword);
  }

Future<void> _login(LoginEvent event, Emitter<AuthState> emit) async {
  try {
    emit(AuthLoading());
    final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
      email: event.email,
      password: event.password
    );
    
    final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    
    if (!userDoc.exists) {
      emit(AuthError('Usuário não encontrado'));
      return;
    }

    final userData = userDoc.data()!;
    emit(Authenticated(UserModel(
      uid: userCredential.user!.uid,
      email: userCredential.user!.email!,
      name: userData['name'] ?? 'Nome não definido', // Tratamento de null
    )));
  } on FirebaseAuthException catch (e) {
    emit(AuthError(e.message ?? 'Erro no login'));
  }
}

  Future<void> _signUp(SignUpEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password
      );

      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': event.name,
        'email': event.email,
        'createdAt': FieldValue.serverTimestamp(),
        'userType': 'client', // Ou 'provider' conforme RF03
      });

      emit(Authenticated(UserModel(
        uid: userCredential.user!.uid,
        email: event.email,
        name: event.name,
      )));
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Erro ao criar conta. Tente novamente.'));
    }
  }

  Future<void> _logout(LogoutEvent event, Emitter<AuthState> emit) async {
    await _auth.signOut();
    emit(Unauthenticated());
  }

  Future<void> _resetPassword(ResetPasswordEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      await _auth.sendPasswordResetEmail(email: event.email);
      emit(PasswordResetSuccess());
    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Erro ao enviar email de recuperação.'));
    }
  }
}