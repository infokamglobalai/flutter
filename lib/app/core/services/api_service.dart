import 'package:dio/dio.dart' as dio;
import 'package:dio_smart_retry/dio_smart_retry.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:get/get.dart';
import 'package:najahapp/app/core/constants/api_constants.dart';
import 'package:najahapp/app/core/services/storage_service.dart';

class ApiService {
  late final dio.Dio _dio;
  final StorageService _storageService = Get.find<StorageService>();
  String? _cachedToken; // in-memory cache to avoid async storage read per request

  ApiService() {
    // Pre-cache the token once at construction time (synchronous prefs read)
    _cachedToken = _storageService.getTokenSync();

    final baseUrl = _resolveBaseUrl();
    _dio = dio.Dio(
      dio.BaseOptions(
        baseUrl: baseUrl,
        // AI endpoints (counsellor, chat) can take longer.
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add Retry Interceptor for better network resilience
    _dio.interceptors.add(
      RetryInterceptor(
        dio: _dio,
        logPrint: print, // log retry attempts for debugging
        retries: 3, // retry up to 3 times
        retryDelays: const [
          Duration(seconds: 1), // wait 1 sec before first retry
          Duration(seconds: 2), // wait 2 sec before second retry
          Duration(seconds: 3), // wait 3 sec before third retry
        ],
        retryableExtraStatuses: {408, 500, 502, 503, 504}, // retry on these status codes
      ),
    );

    // Add interceptors
    _dio.interceptors.add(
      dio.InterceptorsWrapper(
        onRequest: (options, handler) {
          // Use cached token – no async storage read needed
          final token = _cachedToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          final sc = error.response?.statusCode;
          if (sc == 401 || sc == 403) {
            // Clear the in-memory cached token so subsequent requests do not
            // keep using an expired JWT.  Do NOT wipe persistent storage here
            // — token refresh / logout is handled properly by ApiClient.
            // We also treat 403 the same way because many backends (including
            // the Najah backend) return 403 on mentor/role-protected routes
            // when the token is expired rather than 401.
            _cachedToken = null;
          }
          return handler.next(error);
        },
      ),
    );
  }

  String _resolveBaseUrl() {
    if (kIsWeb) {
      final host = Uri.base.host.toLowerCase();
      if (host == 'localhost' || host == '127.0.0.1') {
        // Local backend (CORS enabled in backend dev)
        return 'http://localhost:3000/api';
      }
    }
    return ApiConstants.baseUrl;
  }

  /// Call this after a successful login to keep the cache fresh.
  void updateCachedToken(String token) {
    _cachedToken = token;
  }

  /// Returns true only when an in-memory auth token is present.
  /// Use this as a lightweight guard before making authenticated calls.
  bool get hasToken => _cachedToken != null && _cachedToken!.isNotEmpty;

  // GET request
  Future<dio.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get(path, queryParameters: queryParameters);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // POST request
  Future<dio.Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// POST request expecting binary (bytes) response.
  Future<dio.Response<List<int>>> postBytes(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) async {
    try {
      final response = await _dio.post<List<int>>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: dio.Options(
          responseType: dio.ResponseType.bytes,
          headers: headers,
        ),
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PUT request
  Future<dio.Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // PATCH request
  Future<dio.Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  // DELETE request
  Future<dio.Response> delete(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.delete(
        path,
        queryParameters: queryParameters,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
