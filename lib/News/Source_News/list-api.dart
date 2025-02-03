import 'package:dio/dio.dart';

class ListApi {
  final _baseUrl = 'https://nepaliunicode.org/app/news/json'; //onlinekhabar//
  final Dio _dio;

  ListApi(this._dio);

  Future<Map<String, dynamic>> get({
    required String endPoint,
    required Map<String, dynamic> queryParameters,
  }) async {
    Response response = await _dio.get(
      '$_baseUrl$endPoint',
      queryParameters: queryParameters,
    );
    return response.data;
  }
}
