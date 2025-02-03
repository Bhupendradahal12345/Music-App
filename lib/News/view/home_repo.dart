import 'package:shrayesh_patro/News/errors/failures.dart';
import 'package:shrayesh_patro/News/models_news/news_model.dart';
import 'package:dartz/dartz.dart';


abstract class HomeRepo {
  Future<Either<Failure, List<NewsModel>>> fetchRecommendedNews();
  Future<Either<Failure, List<NewsModel>>> search({required String value});
}
