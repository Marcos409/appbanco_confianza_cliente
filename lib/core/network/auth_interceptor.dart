import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../storage/secure_storage.dart';

class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    debugPrint('[AuthInterceptor] >> ${options.method} ${options.uri}');
    if (options.data is Map) {
      final safeData = Map<String, dynamic>.from(options.data as Map);
      if (safeData.containsKey('password')) safeData['password'] = '***';
      debugPrint('[AuthInterceptor] >> body: $safeData');
    }
    if (!options.path.contains('/login')) {
      final token = await SecureStorage.instance.getToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
        debugPrint('[AuthInterceptor] >> token adjunto: ${token.substring(0, 20)}...');
      }
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[AuthInterceptor] << ${response.statusCode} ${response.requestOptions.path}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[AuthInterceptor] !! ERROR ${err.response?.statusCode} ${err.requestOptions.path} - '
        '${err.message} - body: ${err.response?.data}');
    if (err.response?.statusCode == 401) {
      debugPrint('[AuthInterceptor] !! 401 detectado, limpiando sesión');
      SecureStorage.instance.clearAll();
    }
    handler.next(err);
  }
}
