import 'package:cloud_firestore/cloud_firestore.dart';

class Freelancer {
  final String id;
  final String nome;
  final double avaliacaoMedia;
  final List<String> servicos;
  final String bio;
  final String fotoUrl;
  final GeoPoint localizacao;
  final List<String> portfolio;
  final List<Review> reviews;
  final int servicosConcluidos;

  Freelancer({
    required this.id,
    required this.nome,
    required this.avaliacaoMedia,
    required this.servicos,
    required this.bio,
    required this.fotoUrl,
    required this.localizacao,
    required this.portfolio,
    required this.reviews,
    required this.servicosConcluidos,
  });

  factory Freelancer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Conversão segura para servicosConcluidos
    int parseServicosConcluidos(dynamic value) {
      if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value) ?? 0;
      }
      return 0;
    }

    return Freelancer(
      id: doc.id,
      nome: data['nome'] as String? ?? '',
      avaliacaoMedia: (data['avaliacaoMedia'] as num?)?.toDouble() ?? 0.0,
      servicos: List<String>.from(data['servicos'] ?? []),
      bio: data['bio'] as String? ?? '',
      fotoUrl: data['fotoUrl'] as String? ?? '',
      localizacao: data['localizacao'] is GeoPoint ? data['localizacao'] as GeoPoint : GeoPoint(0, 0),
      portfolio: List<String>.from(data['portfolio'] ?? []),
      reviews: _parseReviews(data['avaliacoes'] ?? []),
      servicosConcluidos: parseServicosConcluidos(data['servicos_concluidos']),
    );
  }

  static List<Review> _parseReviews(List<dynamic> reviews) {
    return reviews.where((item) => item is Map<String, dynamic>).map<Review>((item) {
      return Review.fromFirestore(item as Map<String, dynamic>);
    }).toList();
  }
}

class Review {
  final String usuario;
  final double avaliacao;
  final String comentario;
  final DateTime data;

  Review({
    required this.usuario,
    required this.avaliacao,
    required this.comentario,
    required this.data,
  });

  factory Review.fromFirestore(Map<String, dynamic> data) {
    return Review(
      usuario: data['usuario'] as String? ?? '',
      avaliacao: (data['avaliacao'] as num?)?.toDouble() ?? 0.0,
      comentario: data['comentario'] as String? ?? '',
      data: (data['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
