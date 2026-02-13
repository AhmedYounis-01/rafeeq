import 'dart:developer';
import 'package:dio/dio.dart';
import '../../routing/app_router.dart';

/// API Interceptor for Supabase Backend
///
/// Handles request/response interception and adds Supabase authentication headers
class ApiInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    log('⚡ Interceptor onRequest called with path: ${options.path}');

    // Add Supabase API key to all requests
    options.headers['apikey'] = "Endpoints.supabaseAnonKey";

    // Add Content-Type if not already set
    if (!options.headers.containsKey('Content-Type')) {
      options.headers['Content-Type'] = 'application/json';
    }

    // Log request details for debugging
    log('📤 Request Headers: ${options.headers}');
    if (options.data != null) {
      log('📦 Request Body: ${options.data}');
    }

    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    log('✅ Response received with status code: ${response.statusCode}');
    log('📦 Response data: ${response.data}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    log(
      '⚡ Interceptor onError called with status code: ${err.response?.statusCode}',
    );
    log('⚡ Request path: ${err.requestOptions.path}');
    log('⚠️ Error message: ${err.message}');
    log('⚠️ Error response: ${err.response?.data}');

    // Handle 401 Unauthorized - Session expired or invalid
    if (err.response?.statusCode == 401) {
      log('⚠️ Detected 401 Unauthorized - Session expired or invalid');
      await logout();
      return handler.next(err);
    }

    // Handle 403 Forbidden - Insufficient permissions
    if (err.response?.statusCode == 403) {
      log('⚠️ Detected 403 Forbidden - Insufficient permissions');
    }

    // Handle 404 Not Found
    if (err.response?.statusCode == 404) {
      log('⚠️ Detected 404 Not Found - Resource not found');
    }

    // Handle 500 Internal Server Error
    if (err.response?.statusCode == 500) {
      log('❌ Detected 500 Internal Server Error');
    }

    return handler.next(err);
  }

  /// Logout the user and clear session
  static Future<void> logout() async {
    log('🚪 Logging out user and clearing session');
    // await SessionManager().clearSession();

    // Navigate to login screen using GoRouter
    AppRouter.router.go(AppRouter.signIn);
  }
}
