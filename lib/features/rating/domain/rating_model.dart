import 'package:cloud_firestore/cloud_firestore.dart';

class Rating {
  final String freelancerId;
  final String? solicitacaoId;
  final String clientId;
  final double nota;
  final String comentario;
  final DateTime data;

  Rating({
    required this.freelancerId,
    this.solicitacaoId,
    required this.clientId,
    required this.nota,
    required this.comentario,
    required this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'freelancerId': freelancerId,
      'solicitacaoId': solicitacaoId,
      'clientId': clientId,
      'nota': nota,
      'comentario': comentario,
      'data': Timestamp.fromDate(data),
    };
  }
}