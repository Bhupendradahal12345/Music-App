
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'list5-api.dart';
import 'list5_repo_impl.dart';


final getIt = GetIt.instance;

void list5ServiceLocator() {
  getIt.registerSingleton<List5Api>(List5Api(Dio()));
  getIt.registerSingleton<List5RepoImpl>(List5RepoImpl(
    getIt.get<List5Api>(),
  ));
}
