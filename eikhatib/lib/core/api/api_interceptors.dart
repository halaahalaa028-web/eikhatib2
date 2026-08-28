// ignore_for_file: avoid_print

import 'package:eikhatib/core/api/end_point.dart';
import 'package:eikhatib/core/cache/cache_helper.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ApiInterceptor extends Interceptor {
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.data is! FormData) {
      options.headers['Content-Type'] = 'application/json';
    }

    final token = await secureStorage.read(key: 'token') ?? await SecureCacheHelper().getData(key: ApiKey.token);

    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // 0. Handle Banned Users (403)
    if (err.response?.statusCode == 403 &&
        err.response?.data is Map &&
        err.response?.data['is_banned'] == true) {
      await secureStorage.delete(key: 'token');
      await secureStorage.delete(key: 'refresh_token');
      await SecureCacheHelper().removeData(key: ApiKey.token);
      return super.onError(err, handler);
    }

    // Handle Token Expiry
    if (err.response?.statusCode == 401) {
      final message = err.response?.data is Map ? err.response?.data['message'] : null;
      
      if (message == 'Refresh TokenExpiredError' || message == 'التوكن غير صالح أو منتهي الصلاحية') {
        // Even the refresh token is dead, force logout
        await secureStorage.delete(key: 'token');
        await secureStorage.delete(key: 'refresh_token');
        return super.onError(err, handler);
      }

      // Check if it's an Access Token Expiry and we have a refresh token
      final refreshToken = await secureStorage.read(key: 'refresh_token');
      if (refreshToken != null) {
        try {
          // Attempt to refresh
          final dio = Dio();
          dio.options.baseUrl = EndPoint.baseUrl;
          final response = await dio.post(EndPoint.refreshToken, data: {'refresh_token': refreshToken});
          
          final newAccessToken = response.data['token'];
          await secureStorage.write(key: 'token', value: newAccessToken);
          
          // Retry original request
          final opts = err.requestOptions;
          opts.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await dio.fetch(opts);
          return handler.resolve(retryResponse);
        } catch (e) {
          // Refresh failed
          await secureStorage.delete(key: 'token');
          await secureStorage.delete(key: 'refresh_token');
        }
      } else {
        await secureStorage.delete(key: 'token');
      }
    }
    
    super.onError(err, handler);
  }
}
