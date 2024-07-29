import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:movemore/domain/network/api_error_handler.dart';
import 'package:movemore/domain/auth/auth_interceptor.dart';

Dio dio = setupDio();
Dio setupDio() {
  var dioInstance = Dio(BaseOptions(
    baseUrl: 'https://api.movemo.re:8080',
    //baseUrl: 'https://localhost:8080',
    contentType: 'application/json',
  ));

  _allowAllCertificates(dioInstance);

  dioInstance.interceptors.add(AuthInterceptor());
  dioInstance.interceptors.add(ApiErrorHandler(dioInstance));
  return dioInstance;
}

void _allowAllCertificates(Dio dio) {
  (dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = (cert, host, port) => true;
    return client;
  };
}
