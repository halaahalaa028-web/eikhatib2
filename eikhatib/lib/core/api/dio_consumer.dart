import 'package:eikhatib/core/api/api_consumer.dart';
import 'package:eikhatib/core/api/api_interceptors.dart';
import 'package:eikhatib/core/api/end_point.dart';
import 'package:eikhatib/core/errors/exception.dart';
import 'package:dio/dio.dart';

class DioConsumer extends ApiConsumer {
  DioConsumer({required this.dio}) {
    dio.options.baseUrl = EndPoint.baseUrl;
    dio.interceptors.add(ApiInterceptor());
    dio.interceptors.add(
      InterceptorsWrapper(
        onError: (DioException e, ErrorInterceptorHandler handler) {
          if (e.response?.statusCode == 500 ||
              e.type == DioExceptionType.connectionTimeout ||
              e.type == DioExceptionType.sendTimeout ||
              e.type == DioExceptionType.receiveTimeout ||
              e.type == DioExceptionType.connectionError) {
            // AppRouter.navigatorKey.currentState?.pushNamed(Routes.serverError);
          }
          return handler.next(e);
        },
      ),
    );
    // dio.interceptors.add(
    //   LogInterceptor(
    //     request: true,
    //     requestHeader: true,
    //     requestBody: true,
    //     responseHeader: true,
    //     responseBody: true,

    //     error: true,
    //   ),
    // );
  }
  final Dio dio;

  @override
  Future delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    try {
      final response = await dio.delete(
        path,
        data: (data is FormData)
            ? data
            : (isFromData ? FormData.fromMap(data) : data),
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  @override
  Future get(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  @override
  Future put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    try {
      final response = await dio.put(
        path,
        data: (data is FormData)
            ? data
            : (isFromData ? FormData.fromMap(data) : data),
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }

  @override
  Future post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    try {
      final response = await dio.post(
        path,
        data: (data is FormData)
            ? data
            : (isFromData ? FormData.fromMap(data) : data),
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      if (e.response != null) {}
      handleDioExceptions(e);
    }
  }

  @override
  Future patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    bool isFromData = false,
  }) async {
    try {
      final response = await dio.patch(
        path,
        data: (data is FormData)
            ? data
            : (isFromData ? FormData.fromMap(data) : data),
        queryParameters: queryParameters,
      );
      return response.data;
    } on DioException catch (e) {
      handleDioExceptions(e);
    }
  }
}
