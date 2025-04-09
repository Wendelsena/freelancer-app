import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

@immutable
sealed class SearchEvent {}

class SearchFreelancers extends SearchEvent {
  final String? query;
  final String? servico;
  final GeoPoint? localizacaoUsuario;
  final double? avaliacaoMinima;
  final double raioKm;

  SearchFreelancers({
    this.query,
    this.servico,
    this.localizacaoUsuario,
    this.avaliacaoMinima,
    this.raioKm = 10, // Valor padrão definido
  });
}