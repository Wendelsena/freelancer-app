import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:freela_app/features/freelancer/domain/freelancer_model.dart';

class FreelancerRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<String> _generateSearchKeywords(String nome, List<String> servicos) {
    final keywords = <String>[];
    final nomeLower = nome.toLowerCase();

    // Adiciona o nome completo e substrings
    keywords.add(nomeLower);
    for (int i = 0; i < nomeLower.length; i++) {
      for (int j = i + 1; j <= nomeLower.length; j++) {
        keywords.add(nomeLower.substring(i, j));
      }
    }

    // Adiciona serviços completos e prefixos
    for (final servico in servicos) {
      final servicoLower = servico.toLowerCase();
      keywords.add(servicoLower);
      for (int i = 0; i < servicoLower.length; i++) {
        keywords.add(servicoLower.substring(0, i + 1));
      }
    }

    return keywords.toSet().toList(); // Remove duplicatas
  }

  Future<void> saveFreelancer(Freelancer freelancer) async {
    await _firestore.collection('prestadores').doc(freelancer.id).set({
      'nome': freelancer.nome,
      'servicos': freelancer.servicos,
      'searchKeywords': _generateSearchKeywords(freelancer.nome, freelancer.servicos),
      'avaliacaoMedia': freelancer.avaliacaoMedia,
      'bio': freelancer.bio,
      'fotoUrl': freelancer.fotoUrl,
      'localizacao': freelancer.localizacao,
      'portfolio': freelancer.portfolio,
      'servicos_concluidos': freelancer.servicosConcluidos,
    });
  }

  Future<List<Freelancer>> getFeaturedFreelancers() async {
    try {
      final snapshot = await _firestore
          .collection('prestadores')
          .orderBy('avaliacaoMedia', descending: true)
          .limit(10)
          .get();

      return snapshot.docs.map((doc) => Freelancer.fromFirestore(doc)).toList();
    } on FirebaseException catch (e) {
      throw 'Erro ao buscar prestadores: ${e.message}';
    }
  }

  Future<List<Freelancer>> searchFreelancers({
    String? query,
    String? servico,
    GeoPoint? localizacaoUsuario,
    double raioKm = 10,
    double? avaliacaoMinima,
  }) async {
    try {
      Query queryRef = _firestore.collection('prestadores');

      if (servico != null && servico.isNotEmpty) {
        queryRef = queryRef.where('servicos', arrayContains: servico);
      }

      if (localizacaoUsuario != null) {
        const grausPorKm = 0.008983111;
        final delta = grausPorKm * raioKm;
        queryRef = queryRef
            .where('localizacao.latitude',
                isGreaterThanOrEqualTo: localizacaoUsuario.latitude - delta)
            .where('localizacao.latitude',
                isLessThanOrEqualTo: localizacaoUsuario.latitude + delta);
      }

      if (avaliacaoMinima != null) {
        queryRef = queryRef.where('avaliacaoMedia',
            isGreaterThanOrEqualTo: avaliacaoMinima);
      }

      final snapshot = await queryRef.get();
      List<Freelancer> results = snapshot.docs
          .map((doc) => Freelancer.fromFirestore(doc))
          .toList();

      // Filtro local otimizado
      if (query != null && query.isNotEmpty) {
        final termos = query.toLowerCase().split(' ');
        results = results.where((freelancer) {
          final allSearchableText = [
            ...freelancer.searchKeywords,
            freelancer.nome.toLowerCase(),
            ...freelancer.servicos.map((s) => s.toLowerCase())
          ].join(' ');
          
          return termos.every((termo) => allSearchableText.contains(termo));
        }).toList();
      }

      if (localizacaoUsuario != null) {
        for (var freelancer in results) {
          freelancer.distancia = Geolocator.distanceBetween(
            localizacaoUsuario.latitude,
            localizacaoUsuario.longitude,
            freelancer.localizacao.latitude,
            freelancer.localizacao.longitude,
          );
        }
        results.sort((a, b) => (a.distancia ?? 0).compareTo(b.distancia ?? 0));
      }

      return results;
    } on FirebaseException catch (e) {
      throw 'Erro na busca: ${e.message}';
    }
  }

  Future<void> updateSearchKeywords() async {
    final snapshot = await _firestore.collection('prestadores').get();
    for (var doc in snapshot.docs) {
      final freelancer = Freelancer.fromFirestore(doc);
      await doc.reference.update({
        'searchKeywords': _generateSearchKeywords(
            freelancer.nome, freelancer.servicos)
      });
    }
  }
}