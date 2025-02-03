import 'package:dio/dio.dart';

class List2Api {
  final _baseUrl = 'https://nepaliunicode.org/app/news/json';// bbc
  final Dio _dio;

  List2Api(this._dio);

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
