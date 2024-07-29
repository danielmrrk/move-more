import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "package:jwt_decoder/jwt_decoder.dart";
import 'package:movemore/domain/auth/auth_service.dart';

const kRefreshTokenStorageKey = 'refresh_token';
const kUserIdStorageKey = 'user_id';

const storage = FlutterSecureStorage(aOptions: AndroidOptions(encryptedSharedPreferences: true));

class TokenData {
  const TokenData({
    required this.accessToken,
    required this.refreshToken,
    required this.userId,
    required this.username,
    required this.expiryTimestamp,
  });
  final String accessToken;
  final String refreshToken;
  final int userId;
  final String username;
  final int expiryTimestamp;
}

final _tokenProvider = StateNotifierProvider<TokenService, TokenData?>((ref) {
  return tokenService;
});

final loginStateProvider = Provider<bool>((ref) {
  ref.watch(_tokenProvider);
  return tokenService.isLoggedIn();
});

final tokenService = TokenService();

class TokenService extends StateNotifier<TokenData?> {
  TokenService() : super(null);

  String? get username {
    return state?.username;
  }

  int? get userId {
    return state?.userId;
  }

  TokenData? get token {
    return state;
  }

  bool isLoggedIn() {
    return state != null;
  }

  Future<String> getAccessToken() async {
    assert(state != null);
    if (_tokenIsExpired()) {
      await _refreshLogin(state!.refreshToken, state!.userId);
    }
    return state!.accessToken;
  }

  Future<void> parseAndSetAccessToken(Map<String, dynamic> tokenApiResponse) async {
    final decodedJwt = JwtDecoder.decode(tokenApiResponse["accessToken"]);

    state = TokenData(
      accessToken: tokenApiResponse["accessToken"],
      refreshToken: tokenApiResponse["refreshToken"],
      username: tokenApiResponse["username"],
      userId: decodedJwt["uid"],
      expiryTimestamp: decodedJwt["exp"],
    );

    await storage.write(key: kRefreshTokenStorageKey, value: state!.refreshToken);
    await storage.write(key: kUserIdStorageKey, value: state!.userId.toString());
  }

  Future<void> tryLoginAfterRestart() async {
    if (state != null) {
      return;
    }
    String? refreshToken = await storage.read(key: kRefreshTokenStorageKey);
    int? userId = int.tryParse(await storage.read(key: kUserIdStorageKey) ?? 'NaN');
    if (refreshToken == null || userId == null) {
      return;
    }
    try {
      await _refreshLogin(refreshToken, userId);
    } catch (e) {
      return;
    }
  }

  Future<void> _refreshLogin(String refreshToken, int userId) async {
    final tokenApiResponse = await authService.refreshToken(refreshToken, userId);
    await parseAndSetAccessToken(tokenApiResponse);
    return;
  }

  bool _tokenIsExpired() {
    return state!.expiryTimestamp < DateTime.now().millisecondsSinceEpoch / 1000;
  }
}
