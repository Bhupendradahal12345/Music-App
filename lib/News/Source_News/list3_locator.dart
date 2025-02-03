
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'list3-api.dart';
import 'list3_repo_impl.dart';


final getIt = GetIt.instance;

void list3ServiceLocator() {
  getIt.registerSingleton<List3Api>(List3Api(Dio()));
  getIt.registerSingleton<List3RepoImpl>(List3RepoImpl(
    getIt.get<List3Api>(),
  ));
}
