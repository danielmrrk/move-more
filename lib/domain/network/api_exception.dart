import 'package:dio/dio.dart';

class ApiException extends DioException {
  ApiException({required super.message, required super.requestOptions});
}
