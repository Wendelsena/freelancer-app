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
  final List<String> searchKeywords; // Campo adicionado
  double? distancia;

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
    required this.searchKeywords, // Campo adicionado
    this.distancia,
  });

  factory Freelancer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Freelancer(
      id: doc.id,
      nome: data['nome']?.toString() ?? 'Nome não informado',
      avaliacaoMedia: (data['avaliacaoMedia'] as num?)?.toDouble() ?? 0.0,
      servicos: List<String>.from(data['servicos'] ?? []),
      bio: data['bio']?.toString() ?? '',
      fotoUrl: data['fotoUrl']?.toString() ?? '',
      localizacao: data['localizacao'] is GeoPoint
          ? data['localizacao'] as GeoPoint
          : const GeoPoint(0, 0),
      portfolio: List<String>.from(data['portfolio'] ?? []),
      reviews: _parseReviews(data['avaliacoes']),
      servicosConcluidos: (data['servicos_concluidos'] as num?)?.toInt() ?? 0,
      searchKeywords: List<String>.from(data['searchKeywords'] ?? []), // Mapeado
      distancia: 0.0,
    );
  }

  static List<Review> _parseReviews(dynamic data) {
    try {
      if (data is List) {
        return data
            .whereType<Map<String, dynamic>>()
            .map<Review>((item) => Review.fromFirestore(item))
            .toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}

class Review {
  final String usuarioId;
  final String nomeUsuario; // Campo corrigido
  final double avaliacao;
  final String comentario;
  final DateTime data;

  Review({
    required this.usuarioId,
    required this.nomeUsuario, // Nome corrigido
    required this.avaliacao,
    required this.comentario,
    required this.data,
  });

  factory Review.fromFirestore(Map<String, dynamic> data) {
    return Review(
      usuarioId: data['usuario_id']?.toString() ?? '',
      nomeUsuario: data['nome_usuario']?.toString() ?? 'Anônimo', // Campo corrigido
      avaliacao: (data['avaliacao'] as num?)?.toDouble() ?? 0.0,
      comentario: data['comentario']?.toString() ?? '',
      data: (data['data'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}