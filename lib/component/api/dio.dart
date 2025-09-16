import 'package:dio/dio.dart';

enum HttpMethod {
  get,
  post,
  put,
  delete
}

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://newsapi.org/v2/everything',
    headers: {'Content-Type': 'application/json'},
  ));

  Future<Response> request({
    required String endpoint,
    required String method,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.request(
        endpoint,
        data: (method == 'POST' || method == 'PUT') ? data : null,
        queryParameters: (method == 'GET' || method == 'DELETE') ? queryParams : null,
        options: Options(method: method),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}