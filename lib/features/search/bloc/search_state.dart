import 'package:flutter/foundation.dart';
import 'package:freela_app/features/freelancer/domain/freelancer_model.dart';

@immutable
sealed class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}

class SearchSuccess extends SearchState {
  final List<Freelancer> freelancers;
  SearchSuccess(this.freelancers);
}