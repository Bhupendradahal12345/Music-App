
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'list7-api.dart';
import 'list7_repo_impl.dart';


final getIt = GetIt.instance;

void list7ServiceLocator() {
  getIt.registerSingleton<List7Api>(List7Api(Dio()));
  getIt.registerSingleton<List7RepoImpl>(List7RepoImpl(
    getIt.get<List7Api>(),
  ));
}
