import 'package:movemore/domain/network/api_exception.dart';

class BackendException extends ApiException {
  BackendException({required super.message, required super.requestOptions});
}
