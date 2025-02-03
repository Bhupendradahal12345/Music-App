import 'package:dio/dio.dart';

class List6Api {
  final _baseUrl = 'https://nepaliunicode.org/app/news/json';  //himal khabar
  final Dio _dio;

  List6Api(this._dio);

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
