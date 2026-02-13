import 'package:dio/dio.dart';

import 'api_consumer.dart';
import 'api_interceptor.dart';
import 'server_failure.dart';

class DioConsumer implements ApiConsumer {
  final Dio _dio = Dio();

  DioConsumer() {
    // Set Supabase RPC base URL
    _dio.options.baseUrl = "Endpoints.baseUrl";

    // Add API interceptor for Supabase authentication
    _dio.interceptors.add(ApiInterceptor());

    // Set default headers
    _dio.options.headers.addAll({
      'Content-Type': 'application/json',
      'apikey': "Endpoints.supabaseAnonKey",
    });
  }

  @override
  Future<Response> get(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        endPoint,
        queryParameters: queryParameters,
        options: options ?? Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

  @override
  Future<Response> post(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool isFormData = false,
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        endPoint,
        queryParameters: queryParameters,
        data: isFormData ? FormData.fromMap(data) : data,
        options: options ?? Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

  @override
  Future<Response> put(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool isFormData = false,
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        endPoint,
        queryParameters: queryParameters,
        data: isFormData ? FormData.fromMap(data) : data,
        options: options ?? Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

  @override
  Future<Response> delete(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool isFormData = false,
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        endPoint,
        queryParameters: queryParameters,
        data: isFormData ? FormData.fromMap(data) : data,
        options: options ?? Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }

  @override
  Future<Response> patch(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    bool isFormData = false,
    Map<String, dynamic>? headers,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        endPoint,
        queryParameters: queryParameters,
        data: isFormData ? FormData.fromMap(data) : data,
        options: options ?? Options(headers: headers),
      );
      return response;
    } on DioException catch (e) {
      throw ServerFailure.fromDioException(e);
    }
  }
}
