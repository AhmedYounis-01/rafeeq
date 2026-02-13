import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';

/// Server Failure Handler for Supabase Backend
///
/// Handles error responses from Supabase RPC functions with bilingual support
class ServerFailure {
  final String message;
  final String error;
  final int statusCode;

  const ServerFailure({
    required this.message,
    required this.error,
    required this.statusCode,
  });

  // ==================== Supabase Response Handler ====================

  /// Factory method to handle Supabase RPC function responses
  ///
  /// Supabase returns responses in this format:
  /// ```json
  /// {
  ///   "success": false,
  ///   "message_en": "Error message in English",
  ///   "message_ar": "رسالة الخطأ بالعربية"
  /// }
  /// ```
  factory ServerFailure.fromResponse(Map<String, dynamic> response) {
    // Extract bilingual messages
    final String messageEn = response['message_en'] ?? 'Unknown error occurred';
    // ignore: unused_local_variable
    final String messageAr = response['message_ar'] ?? 'حدث خطأ غير معروف';
    final int statusCode = response['statusCode'] ?? 500;

    // Use English message as default

    // based on app's current language setting
    final String message = messageEn;

    return ServerFailure(
      message: message,
      error: response['error'] ?? 'Server Error',
      statusCode: statusCode,
    );
  }

  // ==================== Dio Exception Handler ====================

  /// Factory method to handle Dio exceptions
  static ServerFailure fromDioException(DioException exception) {
    final response = exception.response?.data;

    debugPrint('DioException details:');
    debugPrint('Type: ${exception.type}');
    debugPrint('Message: ${exception.message}');
    debugPrint('Response data: $response');
    debugPrint('Status code: ${exception.response?.statusCode}');
    debugPrint('Headers: ${exception.response?.headers}');

    // Handle Supabase RPC function error response
    if (response is Map<String, dynamic>) {
      // Check if it's a Supabase error response
      if (response.containsKey('message_en') ||
          response.containsKey('message_ar')) {
        return ServerFailure.fromResponse(response);
      }

      // Handle generic error response
      return ServerFailure(
        message: response['message'] ?? 'An error occurred',
        error: response['error'] ?? 'Server Error',
        statusCode: exception.response?.statusCode ?? 500,
      );
    }

    // Handle connection errors
    if (exception.type == DioExceptionType.connectionError) {
      return ServerFailure(
        message:
            'Unable to connect to server. Please check your internet connection.',
        error: 'Connection Error',
        statusCode: 503,
      );
    }

    // Handle connection timeout
    if (exception.type == DioExceptionType.connectionTimeout) {
      return ServerFailure(
        message: 'Connection timeout. Please try again.',
        error: 'Timeout Error',
        statusCode: 408,
      );
    }

    // Handle receive timeout
    if (exception.type == DioExceptionType.receiveTimeout) {
      return ServerFailure(
        message: 'Server took too long to respond. Please try again.',
        error: 'Timeout Error',
        statusCode: 408,
      );
    }

    // Handle send timeout
    if (exception.type == DioExceptionType.sendTimeout) {
      return ServerFailure(
        message: 'Failed to send request. Please try again.',
        error: 'Timeout Error',
        statusCode: 408,
      );
    }

    // Handle bad response
    if (exception.type == DioExceptionType.badResponse) {
      final statusCode = exception.response?.statusCode ?? 500;

      switch (statusCode) {
        case 400:
          return ServerFailure(
            message: 'Invalid request. Please check your input.',
            error: 'Bad Request',
            statusCode: 400,
          );
        case 401:
          return ServerFailure(
            message: 'Unauthorized. Please login again.',
            error: 'Unauthorized',
            statusCode: 401,
          );
        case 403:
          return ServerFailure(
            message: 'Access denied. You don\'t have permission.',
            error: 'Forbidden',
            statusCode: 403,
          );
        case 404:
          return ServerFailure(
            message: 'Resource not found.',
            error: 'Not Found',
            statusCode: 404,
          );
        case 500:
          return ServerFailure(
            message: 'Internal server error. Please try again later.',
            error: 'Server Error',
            statusCode: 500,
          );
        default:
          return ServerFailure(
            message: 'An error occurred. Please try again.',
            error: 'Server Error',
            statusCode: statusCode,
          );
      }
    }

    // Handle cancel
    if (exception.type == DioExceptionType.cancel) {
      return ServerFailure(
        message: 'Request was cancelled.',
        error: 'Request Cancelled',
        statusCode: 499,
      );
    }

    // Default error
    return ServerFailure(
      message: exception.message ?? 'An unexpected error occurred',
      error: exception.response?.statusMessage ?? 'Unknown Error',
      statusCode: exception.response?.statusCode ?? 500,
    );
  }

  // ==================== Helper Methods ====================

  /// Check if error is unauthorized (401)
  bool get isUnauthorized => statusCode == 401;

  /// Check if error is forbidden (403)
  bool get isForbidden => statusCode == 403;

  /// Check if error is not found (404)
  bool get isNotFound => statusCode == 404;

  /// Check if error is server error (5xx)
  bool get isServerError => statusCode >= 500 && statusCode < 600;

  /// Check if error is client error (4xx)
  bool get isClientError => statusCode >= 400 && statusCode < 500;

  @override
  String toString() =>
      'ServerFailure(error: $error, message: $message, statusCode: $statusCode)';
}
