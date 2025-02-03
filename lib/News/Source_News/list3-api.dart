import 'package:dio/dio.dart';

class List3Api {
  final _baseUrl = 'https://nepaliunicode.org/app/news/json'; //बिजमाण्डु //
  final Dio _dio;

  List3Api(this._dio);

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
