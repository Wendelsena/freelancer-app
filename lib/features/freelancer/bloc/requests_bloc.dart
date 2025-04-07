import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freela_app/features/services/domain/service_request_model.dart';

part 'requests_event.dart';
part 'requests_state.dart';

class RequestsBloc extends Bloc<RequestsEvent, RequestsState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  RequestsBloc() : super(RequestsInitial()) {
    on<LoadRequests>(_onLoadRequests);
    on<UpdateRequestStatus>(_onUpdateStatus);
  }

  Future<void> _onLoadRequests(
    LoadRequests event,
    Emitter<RequestsState> emit,
  ) async {
    emit(RequestsLoading());
    try {
      final userId = 'ID_DO_FREELANCER'; // Substitua pelo ID real (ex: FirebaseAuth)
      final snapshot = await _firestore
          .collection('solicitacoes')
          .where('prestadorId', isEqualTo: userId)
          .get();

      final requests = snapshot.docs
          .map((doc) => ServiceRequest.fromFirestore(doc))
          .toList();
      emit(RequestsLoaded(requests));
    } catch (e) {
      emit(RequestsError('Erro ao carregar solicitações: $e'));
    }
  }

  Future<void> _onUpdateStatus(
    UpdateRequestStatus event,
    Emitter<RequestsState> emit,
  ) async {
    try {
      await _firestore
          .collection('solicitacoes')
          .doc(event.requestId)
          .update({'status': event.newStatus});
      add(LoadRequests()); // Recarrega a lista após atualização
    } catch (e) {
      emit(RequestsError('Erro ao atualizar status: $e'));
    }
  }
}