import 'package:dio/dio.dart';
import 'package:movemore/domain/auth/token_service.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.path.endsWith('/token/refresh')) {
      return handler.next(options);
    }
    if (tokenService.isLoggedIn()) {
      final accessToken = await tokenService.getAccessToken();
      options.headers.putIfAbsent('Authorization', () => 'Bearer $accessToken');
    }
    return handler.next(options);
  }
}
