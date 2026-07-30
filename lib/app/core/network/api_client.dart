import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart' hide Response, FormData, MultipartFile;
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/core/constants/app_constants.dart';
import 'package:najahapp/app/core/services/storage_service.dart';
import 'package:najahapp/app/routes/app_pages.dart';

import 'package:najahapp/app/core/config/tenant_config.dart';

class ApiClient {
  late Dio _dio;
  final StorageService _storageService = Get.find<StorageService>();

  ApiClient() {
    final baseUrl = _resolveBaseUrl();
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: AppConstants.connectionTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'x-tenant-slug': TenantConfig.tenantSlug,
          'x-tenant-domain': TenantConfig.tenantDomain,
        },
      ),
    );

    _setupInterceptors();
  }

  String _resolveBaseUrl() {
    if (kIsWeb) {
      final host = Uri.base.host.toLowerCase();
      if (host == 'localhost' || host == '127.0.0.1') {
        return 'http://localhost:3000/api';
      }
    }
    return ApiConstants.baseUrl;
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Always ensure tenant headers are present
          options.headers['x-tenant-slug'] = TenantConfig.tenantSlug;
          options.headers['x-tenant-domain'] = TenantConfig.tenantDomain;

          // Add auth token to requests
          final token = await _storageService.getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          return handler.next(response);
        },
        onError: (DioException error, handler) async {
          final statusCode = error.response?.statusCode;
          final requestPath = error.requestOptions.path;

          // Don't auto-handle 401/403 for login/register/auth endpoints
          // Let the calling code handle these errors
          final authEndpoints = [
            ApiConstants.login,
            ApiConstants.register,
            ApiConstants.forgotPassword,
            ApiConstants.verifyOtp,
            ApiConstants.resetPassword,
            ApiConstants.sendVerificationOtp,
            ApiConstants.verifyStudentOtp,
          ];

          final isAuthEndpoint = authEndpoints.any(
            (endpoint) =>
                requestPath.contains(endpoint) ||
                endpoint.contains(requestPath),
          );

          if ((statusCode == 401 || statusCode == 403) && isAuthEndpoint) {
            // For auth endpoints, let the error pass through
            return handler.next(error);
          }

          if (statusCode == 401) {
            final msg = (error.response?.data?['message'] ?? '')
                .toString()
                .toLowerCase();
            if (msg.contains('session has been terminated') ||
                msg.contains('invalid token') ||
                msg.contains('token has expired') ||
                msg.contains('user not found')) {
              final token = await _storageService.getToken();
              if (token != null && token.isNotEmpty) {
                await _handleUnauthorized();
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await _dio.post(
        ApiConstants.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final data = response.data;
        await _storageService.saveToken(data['token']);
        await _storageService.saveRefreshToken(data['refresh_token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<void> _handleUnauthorized() async {
    await _storageService.clearAuth();
    if (Get.currentRoute != Routes.LOGIN) {
      Get.offAllNamed(Routes.LOGIN);
    }
  }

  // GET Request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // POST Request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PUT Request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // DELETE Request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // PATCH Request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Upload File
  Future<Response> uploadFile(
    String path,
    String filePath, {
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
        ...?data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );
      return response;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Error Handler
  String _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.sendTimeout:
        return AppConstants.errorTimeout;

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return 'Request cancelled';

      case DioExceptionType.connectionError:
        return AppConstants.errorNetwork;

      default:
        return AppConstants.errorGeneric;
    }
  }

  String _handleResponseError(Response? response) {
    if (response == null) return AppConstants.errorGeneric;

    // Try to extract message from response data
    String? errorMessage;
    if (response.data is Map<String, dynamic>) {
      errorMessage = response.data['message'] as String?;
    }

    switch (response.statusCode) {
      case 400:
        return errorMessage ?? 'Bad request';
      case 401:
        return errorMessage ?? AppConstants.errorUnauthorized;
      case 403:
        return errorMessage ?? 'Access forbidden';
      case 404:
        return errorMessage ?? 'Resource not found';
      case 500:
      case 502:
      case 503:
        return errorMessage ?? AppConstants.errorServerError;
      default:
        return errorMessage ?? AppConstants.errorGeneric;
    }
  }
}
