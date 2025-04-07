part of 'search_bloc.dart';

abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchSuccess extends SearchState {
  final List<Freelancer> freelancers;
  SearchSuccess(this.freelancers);
}

class SearchError extends SearchState {
  final String message;
  SearchError(this.message);
}