part of 'service_request_bloc.dart';

abstract class ServiceRequestEvent {}

class SubmitServiceRequest extends ServiceRequestEvent {
  final String freelancerId;
  final String descricao;
  final DateTime prazo;
  final double orcamento;

  SubmitServiceRequest({
    required this.freelancerId,
    required this.descricao,
    required this.prazo,
    required this.orcamento,
  });
}