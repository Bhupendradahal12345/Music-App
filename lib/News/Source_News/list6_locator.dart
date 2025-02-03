
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'list6-api.dart';
import 'list6_repo_impl.dart';


final getIt = GetIt.instance;

void list6ServiceLocator() {
  getIt.registerSingleton<List6Api>(List6Api(Dio()));
  getIt.registerSingleton<List6RepoImpl>(List6RepoImpl(
    getIt.get<List6Api>(),
  ));
}
