part of 'requests_bloc.dart';

abstract class RequestsEvent {}

class LoadRequests extends RequestsEvent {}

class UpdateRequestStatus extends RequestsEvent {
  final String requestId;
  final String newStatus;

  UpdateRequestStatus({
    required this.requestId,
    required this.newStatus,
  });
}