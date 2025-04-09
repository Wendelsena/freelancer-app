import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:freela_app/features/freelancer/domain/data/freelancer_repository.dart';
import 'package:freela_app/features/search/bloc/search_event.dart';
import 'package:freela_app/features/search/bloc/search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final FreelancerRepository repository;

  SearchBloc(this.repository) : super(SearchInitial()) {
    on<SearchFreelancers>(
      _onSearch,
      transformer: debounce(const Duration(milliseconds: 300)),
    );
  }

  EventTransformer<SearchEvent> debounce<SearchEvent>(Duration duration) {
    return (events, mapper) => events.debounceTime(duration).switchMap(mapper);
  }

  Future<void> _onSearch(
    SearchFreelancers event,
    Emitter<SearchState> emit,
  ) async {
    emit(SearchLoading());
    try {
      final results = await repository.searchFreelancers(
        query: event.query,
        servico: event.servico,
        localizacaoUsuario: event.localizacaoUsuario,
        avaliacaoMinima: event.avaliacaoMinima,
        raioKm: event.raioKm,
      );
      emit(SearchSuccess(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}