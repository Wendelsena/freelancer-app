import 'package:bloc/bloc.dart';
import 'package:freela_app/features/freelancer/domain/data/freelancer_repository.dart';
import 'package:freela_app/features/freelancer/domain/freelancer_model.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final FreelancerRepository _freelancerRepository;

  HomeBloc(this._freelancerRepository) : super(HomeInitial()) {
    on<LoadFeaturedFreelancers>(_onLoadFeaturedFreelancers);
  }

  Future<void> _onLoadFeaturedFreelancers(
    LoadFeaturedFreelancers event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    try {
      final freelancers = await _freelancerRepository.getFeaturedFreelancers();
      emit(HomeLoaded(freelancers));
    } catch (e) {
      emit(HomeError('Falha ao carregar prestadores: ${e.toString()}'));
    }
  }
}