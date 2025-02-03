import 'package:shrayesh_patro/News/errors/failures.dart';
import 'package:shrayesh_patro/News/view/home_repo.dart';
import 'package:shrayesh_patro/News/models_news/news_model.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'recommended_news_state.dart';

class RecommendedNewsCubit extends Cubit<RecommendedNewsState> {
  RecommendedNewsCubit(this.homeRepo) : super(RecommendedNewsInitial());
  final HomeRepo homeRepo;

  Future<void> fetchRecommendedNews() async {
    emit(RecommendedNewsLoadingState());
    Either<Failure, List<NewsModel>> result =
        await homeRepo.fetchRecommendedNews();
    result.fold((failure) {
      emit(RecommendedNewsFailureState(failure.errMessage));
    }, (news) {
      emit(RecommendedNewsSuccessState(news));
    });
  }
}
