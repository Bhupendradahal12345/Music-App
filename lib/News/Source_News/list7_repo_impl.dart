import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:shrayesh_patro/News/errors/failures.dart';
import 'package:shrayesh_patro/News/view/home_repo.dart';
import 'package:shrayesh_patro/News/models_news/news_model.dart';
import 'list7-api.dart';

class List7RepoImpl implements HomeRepo {
  final List7Api apiService;
  List7RepoImpl(this.apiService);

  @override
  Future<Either<Failure, List<NewsModel>>> fetchRecommendedNews() async {
    try {
      Map<String, dynamic> data = await apiService.get(
        endPoint: '/feed06.json',

        queryParameters: {
          'pageSize': 4,

        },
      );
      List<NewsModel> recommendedNews = [];
      for (var article in data['articles']) {
        recommendedNews.add(NewsModel.fromJson(article));
      }
      return right(recommendedNews);
    } catch (e) {
      if (e is DioError) {
        return left(ServerFailure(e.toString()));
      }
      return left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NewsModel>>> search(
      {required String value}) async {
    try {
      Map<String, dynamic> data = await apiService.get(
        endPoint: '/feed06.json',
        queryParameters: {


        },
      );
      List<NewsModel> searchResult = [];
      for (var article in data['articles']) {
        searchResult.add(NewsModel.fromJson(article));
      }
      return right(searchResult);
    } catch (e) {
      if (e is DioError) {
        return left(ServerFailure(e.toString()));
      }
      return left(ServerFailure(e.toString()));
    }
  }
}
