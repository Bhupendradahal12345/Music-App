import 'package:dio/dio.dart';

class List4Api {
  final _baseUrl = 'https://nepaliunicode.org/app/news/json'; //deshsansar
  final Dio _dio;

  List4Api(this._dio);

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
