import 'package:dio/dio.dart';

abstract class ApiConsumer {
  Future<Response> get(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    Map<String, dynamic>? headers,
  });

  Future<Response> post(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    Map<String, dynamic>? headers,
  });

  Future<Response> put(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    Map<String, dynamic>? headers,
  });

  Future<Response> delete(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    Map<String, dynamic>? headers,
  });

  Future<Response> patch(
    String endPoint, {
    Map<String, dynamic>? queryParameters,
    Object? data,
    bool isFormData = false,
    Map<String, dynamic>? headers,
  });
}
