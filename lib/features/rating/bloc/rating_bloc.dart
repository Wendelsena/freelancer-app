import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freela_app/features/rating/bloc/rating_event.dart';
import 'package:freela_app/features/rating/bloc/rating_state.dart';

class RatingBloc extends Bloc<RatingEvent, RatingState> {
  final FirebaseFirestore firestore;

  RatingBloc({required this.firestore}) : super(RatingInitial()) {
    on<SubmitRatingEvent>(_handleSubmitRating);
  }

  Future<void> _handleSubmitRating(
    SubmitRatingEvent event,
    Emitter<RatingState> emit,
  ) async {
    try {
      emit(RatingLoading());
      
      await firestore.collection('avaliacoes').add(event.rating.toMap());
      
      final freelancerDoc = firestore.collection('prestadores').doc(event.rating.freelancerId);
      final freelancerData = await freelancerDoc.get();
      
      final totalAvaliacoes = (freelancerData['totalAvaliacoes'] ?? 0) + 1;
      final novaMedia = ((freelancerData['avaliacaoMedia'] ?? 0) * (totalAvaliacoes - 1) + event.rating.nota) / totalAvaliacoes;

      await freelancerDoc.update({
        'avaliacaoMedia': novaMedia,
        'totalAvaliacoes': totalAvaliacoes,
      });
      
      emit(RatingSuccess());
    } catch (e) {
      emit(RatingError("Erro ao avaliar: ${e.toString()}"));
    }
  }
}