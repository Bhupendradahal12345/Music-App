
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'list4-api.dart';
import 'list4_repo_impl.dart';


final getIt = GetIt.instance;

void list4ServiceLocator() {
  getIt.registerSingleton<List4Api>(List4Api(Dio()));
  getIt.registerSingleton<List4RepoImpl>(List4RepoImpl(
    getIt.get<List4Api>(),
  ));
}
