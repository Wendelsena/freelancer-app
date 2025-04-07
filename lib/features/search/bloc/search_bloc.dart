import 'package:bloc/bloc.dart';
import 'package:freela_app/features/freelancer/domain/data/freelancer_repository.dart';
import 'package:freela_app/features/freelancer/domain/freelancer_model.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final FreelancerRepository _repository;

  SearchBloc(this._repository) : super(SearchInitial()) {
    on<SearchFreelancers>(_onSearch);
  }

  Future<void> _onSearch(SearchFreelancers event, Emitter<SearchState> emit) async {
    emit(SearchLoading());
    try {
      final results = await _repository.searchFreelancers(
        query: event.query,
        servico: event.servico,
        localizacao: event.localizacao,
      );
      emit(SearchSuccess(results));
    } catch (e) {
      emit(SearchError('Falha na busca: ${e.toString()}'));
    }
  }
}