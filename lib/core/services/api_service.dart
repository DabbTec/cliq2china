import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide Response;
import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../utils/currency_service.dart';
import 'token_service.dart';

class ApiService extends GetxService {
  late Dio _dio;
  final TokenService _tokenService = Get.find<TokenService>();

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors for auth tokens and currency
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add Auth Token
          final token = _tokenService.accessToken;
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          // Add Currency Parameter automatically
          try {
            final currencyService = Get.find<CurrencyService>();
            final currencyCode = currencyService.localCurrencyCode;
            options.queryParameters['currency'] = currencyCode;
          } catch (e) {
            // CurrencyService might not be initialized yet
            debugPrint(
              'CurrencyService not available for request: ${options.path}',
            );
          }

          return handler.next(options);
        },
        onError: (DioException e, handler) async {
          if (e.response?.statusCode == 401 &&
              _tokenService.accessToken != null) {
            // Attempt to refresh token
            try {
              final refreshed = await refreshToken();
              if (refreshed) {
                // Retry original request
                final options = e.requestOptions;
                options.headers['Authorization'] =
                    'Bearer ${_tokenService.accessToken}';
                final response = await _dio.fetch(options);
                return handler.resolve(response);
              }
            } catch (refreshError) {
              debugPrint('Token refresh failed: $refreshError');
            }
          }

          String errorMessage = 'Something went wrong';

          if (e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.sendTimeout) {
            errorMessage =
                'Connection timed out. Please check your internet or server status.';
          } else if (e.type == DioExceptionType.connectionError) {
            errorMessage = 'No internet connection or server is unreachable.';
          } else if (e.response != null) {
            // Handle specific backend errors
            final data = e.response?.data;
            if (data is Map && data.containsKey('message')) {
              errorMessage = data['message'];
            } else if (data is Map && data.containsKey('error')) {
              errorMessage = data['error'];
            } else {
              errorMessage = 'Server error: ${e.response?.statusCode}';
            }
          }

          debugPrint('API Error: $errorMessage');
          return handler.next(e);
        },
      ),
    );
  }

  Future<bool> refreshToken() async {
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await Dio().post(
        '${ApiEndpoints.baseUrl}${ApiEndpoints.tokenRefresh}',
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        _tokenService.setAccessToken(newAccessToken);
        return true;
      }
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      await _tokenService.clearTokens();
      // Potentially trigger logout in AuthController
    }
    return false;
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) async {
    return await _dio.delete(path, data: data);
  }
}
