import 'package:movemore/domain/network/api_exception.dart';

class NetworkException extends ApiException {
  NetworkException({required super.message, required super.requestOptions});
}
