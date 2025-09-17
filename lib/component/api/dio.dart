import 'package:dio/dio.dart';

enum HttpMethod { GET, POST, PUT, DELETE }

class ApiService {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://newsapi.org/v2',
    headers: {'Content-Type': 'application/json'},
  ));

  Future<Response> request({
    required String endpoint,
    required HttpMethod method,
    Map<String, dynamic>? queryParams,
    Map<String, dynamic>? data,
  }) async {
    try {
      switch (method) {
        case HttpMethod.GET:
          return await _dio.get(endpoint, queryParameters: queryParams);
        case HttpMethod.POST:
          return await _dio.post(endpoint, data: data);
        case HttpMethod.PUT:
          return await _dio.put(endpoint, data: data);
        case HttpMethod.DELETE:
          return await _dio.delete(endpoint, queryParameters: queryParams);
      }
    } catch (e) {
      rethrow;
    }
  }
}
