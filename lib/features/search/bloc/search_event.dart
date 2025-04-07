part of 'search_bloc.dart';

abstract class SearchEvent {}

class SearchFreelancers extends SearchEvent {
  final String? query;
  final String? servico;
  final String? localizacao;
  final double? avaliacaoMinima; // Novo campo

  SearchFreelancers({
    this.query,
    this.servico,
    this.localizacao,
    this.avaliacaoMinima, // Adicionado
  });
}