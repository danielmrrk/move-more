import 'package:movemore/domain/network/dio_provider.dart';

final accountRecoveryService = AccountRecoveryService();

class AccountRecoveryService {
  Future<bool> requestRecoveryCode(String emailOrUsername) async {
    final requestRecoveryCodeResponse = await dio.post('/recover/request-code', data: {
      "emailOrUsername": emailOrUsername,
    });
    return requestRecoveryCodeResponse.statusCode == 200;
  }

  Future<bool> validateRecoveryCode(String emailOrUsername, String recoveryCode) async {
    final validateRecoveryCodeResponse = await dio.post('/recover/validate-code', data: {
      "emailOrUsername": emailOrUsername,
      "recoveryCode": recoveryCode,
    });
    return validateRecoveryCodeResponse.data.valid == true;
  }

  Future<bool> resetPassword(String emailOrUsername, String recoveryCode, String newPassword) async {
    final resetPasswordResponse = await dio.post('/recover/reset-password', data: {
      "emailOrUsername": emailOrUsername,
      "recoveryCode": recoveryCode,
      "newPassword": newPassword,
    });
    return resetPasswordResponse.statusCode == 200;
  }
}
