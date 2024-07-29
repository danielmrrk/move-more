import 'package:dio/dio.dart';
import 'package:movemore/domain/network/backend_exception.dart';
import 'package:movemore/domain/network/network_exception.dart';

class ApiErrorHandler extends Interceptor {
  Dio dio;
  ApiErrorHandler(this.dio);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (!_isMoveMoreBackendError(err)) {
      if (await _retry(err.requestOptions, handler)) {
        return;
      }
      final errorMessage = err.message ?? 'could not connect to backend. Please try again later...';
      return handler.next(NetworkException(message: errorMessage, requestOptions: err.requestOptions));
    }
    final message = err.response!.data['error'];
    return handler.next(BackendException(message: message, requestOptions: err.requestOptions));
  }

  bool _isMoveMoreBackendError(err) {
    return err.response != null && err.response.data != null && err.response!.data['error'] != null;
  }

  Future<bool> _retry(RequestOptions requestOptions, ErrorInterceptorHandler handler) async {
    final int retriesPerformed = requestOptions.extra.update('retries', (value) => ++value, ifAbsent: () => 0);
    if (retriesPerformed < 3) {
      await Future.delayed(Duration(seconds: retriesPerformed));
      dio.fetch(requestOptions).then((response) => handler.resolve(response)).catchError((error) => handler.reject(error));
      return true;
    }
    return false;
  }
}
