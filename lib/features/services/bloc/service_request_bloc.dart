import 'dart:developer';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'service_request_event.dart';
part 'service_request_state.dart';

class ServiceRequestBloc extends Bloc<ServiceRequestEvent, ServiceRequestState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ServiceRequestBloc() : super(ServiceRequestInitial()) {
    on<SubmitServiceRequest>(_onSubmitRequest);
  }

  Future<void> _onSubmitRequest(
    SubmitServiceRequest event,
    Emitter<ServiceRequestState> emit,
  ) async {
    emit(ServiceRequestLoading());
    try {
      await _firestore.collection('solicitacoes').add({
        'freelancerId': event.freelancerId,
        'clienteId': 'ID_DO_CLIENTE', 
        'descricao': event.descricao,
        'prazo': Timestamp.fromDate(event.prazo),
        'orcamento': event.orcamento,
        'status': 'pendente',
        'dataSolicitacao': Timestamp.now(),
      });
      emit(ServiceRequestSuccess());
    } catch (e) {
      log('Erro ao enviar solicitação: $e');
      emit(ServiceRequestError('Falha ao enviar solicitação'));
    }
  }
}