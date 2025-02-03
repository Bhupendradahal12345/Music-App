
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'list2-api.dart';
import 'list2_repo_impl.dart';


final getIt = GetIt.instance;

void list2ServiceLocator() {
  getIt.registerSingleton<List2Api>(List2Api(Dio()));
  getIt.registerSingleton<List2RepoImpl>(List2RepoImpl(
    getIt.get<List2Api>(),
  ));
}
