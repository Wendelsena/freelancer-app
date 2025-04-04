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
      
      // 1. Autenticar usuário
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password
      );

      // 2. Buscar dados complementares no Firestore
      final DocumentSnapshot userDoc = await _firestore
        .collection('clientes')
        .doc(userCredential.user!.uid)
        .get();

      if (!userDoc.exists) {
        await _auth.signOut();
        emit(AuthError('Conta não registrada no sistema'));
        return;
      }

      // 3. Mapear dados para o modelo
      final Map<String, dynamic> userData = userDoc.data()! as Map<String, dynamic>;
      
      emit(Authenticated(UserModel(
        uid: userCredential.user!.uid,
        email: userData['email'] ?? event.email,
        name: userData['nome'] ?? 'Usuário',
        telefone: userData['telefone'],
        userType: userData['tipo'] ?? 'cliente',
        rating: (userData['avaliacao'] ?? 0.0).toDouble(),
                                  )
                        )
          );

    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Falha na autenticação'));
    } on FirebaseException catch (e) {
      emit(AuthError('Erro no banco de dados: ${e.message}'));
    } catch (e) {
      emit(AuthError('Erro inesperado: ${e.toString()}'));
    }
  }

  Future<void> _signUp(SignUpEvent event, Emitter<AuthState> emit) async {
    try {
      emit(AuthLoading());
      
      // 1. Criar conta de autenticação
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password
      );

      // 2. Salvar dados adicionais no Firestore
      await _firestore.collection('clientes')
        .doc(userCredential.user!.uid)
        .set({
          'nome': event.name,
          'email': event.email,
          'senha' : event.password,
          'telefone' : event.telefone,
          'tipo': 'cliente',
          'data_criacao': FieldValue.serverTimestamp(),
          'avaliacao': 0.0
        });

      // 3. Autenticar usuário
      emit(Authenticated(UserModel(
        uid: userCredential.user!.uid,
        email: event.email,
        name: event.name,
        telefone: event.telefone,
        userType: 'cliente',
        rating: 0.0
      )));

    } on FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Falha ao criar conta'));
    } on FirebaseException catch (e) {
      emit(AuthError('Erro no banco de dados: ${e.message}'));
    } catch (e) {
      emit(AuthError('Erro inesperado: ${e.toString()}'));
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
      emit(AuthError(e.message ?? 'Falha ao enviar email'));
    } catch (e) {
      emit(AuthError('Erro inesperado: ${e.toString()}'));
    }
  }
}