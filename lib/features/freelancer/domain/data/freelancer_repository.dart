import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freela_app/features/freelancer/domain/freelancer_model.dart';

class FreelancerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Retorna os 10 freelancers com maior avaliação.
  Future<List<Freelancer>> getFeaturedFreelancers() async {
    try {
      final snapshot = await _firestore
          .collection('prestadores')
          .orderBy('avaliacaoMedia', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => Freelancer.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar prestadores: $e');
    }
  }

  /// Busca freelancers de acordo com filtros opcionais.
  Future<List<Freelancer>> searchFreelancers({
    String? query,
    String? servico,
    String? localizacao,
    double? avaliacaoMinima,
  }) async {
    try {
      Query queryRef = _firestore.collection('prestadores');

      if (servico != null && servico.isNotEmpty) {
        queryRef = queryRef.where('servicos', arrayContains: servico);
      }

      if (localizacao != null && localizacao.isNotEmpty) {
        queryRef = queryRef.where('localizacao', isEqualTo: localizacao);
      }

      if (avaliacaoMinima != null) {
        queryRef = queryRef.where('avaliacaoMedia', isGreaterThanOrEqualTo: avaliacaoMinima);
      }

      if (query != null && query.isNotEmpty) {
        // Aqui, dependendo da necessidade, você pode usar 'isGreaterThanOrEqualTo' ou '>=',
        // mas geralmente usa-se para pesquisa textual com outro tipo de index (ex: Firestore full-text search, Algolia, etc).
        queryRef = queryRef.where('nome', isGreaterThanOrEqualTo: query);
      }

      final snapshot = await queryRef.get();
      return snapshot.docs.map((doc) => Freelancer.fromFirestore(doc)).toList();
    } catch (e) {
      throw Exception('Erro na busca: $e');
    }
  }
}
