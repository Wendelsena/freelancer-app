part of 'requests_bloc.dart';

abstract class RequestsState {}

class RequestsInitial extends RequestsState {}

class RequestsLoading extends RequestsState {}

class RequestsLoaded extends RequestsState {
  final List<ServiceRequest> requests;
  RequestsLoaded(this.requests);
}

class RequestsError extends RequestsState {
  final String message;
  RequestsError(this.message);
}