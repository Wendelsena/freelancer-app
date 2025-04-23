import 'package:flutter/foundation.dart';
import 'package:freela_app/features/rating/domain/rating_model.dart';

@immutable
abstract class RatingEvent {}

class SubmitRatingEvent extends RatingEvent {
  final Rating rating;
  SubmitRatingEvent(this.rating);
}