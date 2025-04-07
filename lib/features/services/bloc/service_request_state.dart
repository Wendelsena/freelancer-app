part of 'service_request_bloc.dart';

abstract class ServiceRequestState {}

class ServiceRequestInitial extends ServiceRequestState {}

class ServiceRequestLoading extends ServiceRequestState {}

class ServiceRequestSuccess extends ServiceRequestState {}

class ServiceRequestError extends ServiceRequestState {
  final String message;
  ServiceRequestError(this.message);
}