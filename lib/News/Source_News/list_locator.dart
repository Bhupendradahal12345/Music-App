
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import 'list-api.dart';
import 'list_repo_impl.dart';

final getIt = GetIt.instance;

void listServiceLocator() {
  getIt.registerSingleton<ListApi>(ListApi(Dio()));
  getIt.registerSingleton<ListRepoImpl>(ListRepoImpl(
    getIt.get<ListApi>(),
  ));
}
