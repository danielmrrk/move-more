import 'package:google_sign_in/google_sign_in.dart';
import 'package:movemore/domain/auth/auth_exception.dart';
import 'package:movemore/domain/auth/not_logged_in_exception.dart';
import 'package:movemore/domain/auth/oauth_provider.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/domain/network/dio_provider.dart';
import 'package:movemore/domain/auth/token_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

const kUserNotRegisteredErrorName = "TECHNICAL_USER_NOT_REGISTERED";

final authService = AuthService();

class AuthService {
  Future<bool> isEmailAvailable(String email) async {
    final isAvailableResponse = await dio.get('/user/email/$email/status');
    return isAvailableResponse.data["isAvailable"] == true;
  }

  Future<bool> register(Object registerPayload) async {
    final registerResponse = await dio.post('/user/register', data: registerPayload);
    return registerResponse.statusCode == 200;
  }

  Future<bool> login(Object loginPayload) async {
    final loginResponse = await dio.post('/user/login', data: loginPayload);
    if (loginResponse.statusCode == 200) {
      tokenService.parseAndSetAccessToken(loginResponse.data);
      return true;
    }
    return false;
  }

  Future<bool> logout() async {
    final logoutResponse = await dio.get('/user/logout');
    return logoutResponse.statusCode == 200;
  }

  Future<bool> delete() async {
    final deleteResponse = await dio.delete('/user');
    return deleteResponse.statusCode == 200;
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken, int userId) async {
    final refreshResponse = await dio.post<Map<String, dynamic>>(
      '/token/refresh',
      data: {
        "refreshToken": refreshToken,
        "userId": userId,
      },
    );

    if (refreshResponse.data != null) {
      return refreshResponse.data!;
    }
    throw NotLoggedInException();
  }

  loginInWithOAuth(OAuthInformation oauthInformation) async {
    try {
      final loginResponse = await dio.post('/oauth/login', data: {
        "token": oauthInformation.idToken,
        "provider": oauthInformation.provider.name,
      });

      tokenService.parseAndSetAccessToken(loginResponse.data);
    } on ApiException catch (e) {
      if (e.message == kUserNotRegisteredErrorName) {
        throw UserNotRegisteredException();
      }
      rethrow;
    }
  }

  registerWithOAuth(String username, OAuthInformation oauthInformation) async {
    final loginResponse = await dio.post('/oauth/register', data: {
      "token": oauthInformation.idToken,
      "username": username,
      "provider": oauthInformation.provider.name,
    });
    tokenService.parseAndSetAccessToken(loginResponse.data);
  }

  Future<OAuthInformation?> authorizeGoogleAccess() async {
    GoogleSignIn googleSignIn = GoogleSignIn(scopes: ['email', 'openid'], serverClientId: kServerGoogleClientId);
    try {
      final gUser = await googleSignIn.signIn();
      if (gUser == null) {
        return null;
      }
      final authentication = await gUser.authentication;

      if (authentication.idToken == null) {
        return null;
      }

      return OAuthInformation(
        id: gUser.id,
        idToken: authentication.idToken!,
        provider: OAuthProvider.google,
      );
    } catch (error) {
      return null;
    }
  }

  authorizeAppleAccess() async {
    try {
      final credentials = await SignInWithApple.getAppleIDCredential(scopes: [
        AppleIDAuthorizationScopes.email,
      ]);

      if (credentials.userIdentifier == null || credentials.identityToken == null) {
        return null;
      }

      return OAuthInformation(
        id: credentials.userIdentifier!,
        idToken: credentials.identityToken!,
        provider: OAuthProvider.apple,
      );
    } catch (error) {
      return null;
    }
  }
}

class OAuthInformation {
  final String id;
  final String idToken;
  final OAuthProvider provider;

  const OAuthInformation({required this.id, required this.idToken, required this.provider});
}
