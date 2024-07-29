import 'dart:io';

import 'package:android_play_install_referrer/android_play_install_referrer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movemore/domain/auth/token_service.dart';
import 'package:movemore/domain/friend/friend_service.dart';
import 'package:share_plus/share_plus.dart';

final invitationService = InvitationService();

const kStorageKeyAppWasOpenedBefore = 'app_first_opening';
const kStorageKeyLastInviteFriendBannerDismissDate = 'last_invite_banner_dismiss_date';

final kInvitationCodePattern = RegExp('/^[0-9a-zA-Z]{8}\$/');
final kInstallReferrerPattern = RegExp('/movemo.re/[a-zA-Z0-9]{3,16}/[0-9a-zA-Z]{8}\$/');

const storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
);

class InvitationService {
  bool? _isFirstAppOpening;
  int _lastInviteLinkTimestamp = 0;
  String? _lastInvitationLink;

  Future<void> openInvitationShareDialog() async {
    if (DateTime.now().millisecondsSinceEpoch - _lastInviteLinkTimestamp > 1000 * 60 * 60) {
      _lastInviteLinkTimestamp = DateTime.now().millisecondsSinceEpoch;
      _lastInvitationLink = await _getInvitationLink();
    }
    Share.share('Ready to loose against me? $_lastInvitationLink', subject: 'Come join me on MoveMore');
  }

  /// returns shouldShowFriendScreen
  Future<bool> onAppStartedAndLoggedIn() async {
    if (await _appWasOpenedBefore()) {
      return false;
    }
    await _setAppWasOpened();

    final invitationCode = await _readInvitationCode();
    if (invitationCode == null) {
      return false;
    }
    final tokenValid = await friendService.redeemFriendAddToken(invitationCode);
    return !tokenValid;
  }

  Future<String?> getReferrerUsername() async {
    if (!Platform.isAndroid) {
      return null;
    }
    try {
      ReferrerDetails referrer = await AndroidPlayInstallReferrer.installReferrer;
      if (referrer.installReferrer == null || !kInstallReferrerPattern.hasMatch(referrer.installReferrer!)) {
        return null;
      }
      final pathSegments = referrer.installReferrer!.split('/');
      final username = pathSegments[pathSegments.length - 2];
      return username;
    } catch (e) {
      return null;
    }
  }

  Future<bool> wasBannerDismissedWithin4Days() async {
    final lastDismissedDate = await storage.read(key: kStorageKeyLastInviteFriendBannerDismissDate);
    if (lastDismissedDate == null) {
      return false;
    }
    final lastDismissedDateMillis = int.parse(lastDismissedDate);
    final nowMillis = DateTime.now().millisecondsSinceEpoch;
    const fourDaysMillis = 4 * 24 * 60 * 60 * 1000;
    return nowMillis - lastDismissedDateMillis < fourDaysMillis;
  }

  Future<void> storeBannerDismissed() {
    return storage.write(key: kStorageKeyLastInviteFriendBannerDismissDate, value: DateTime.now().millisecondsSinceEpoch.toString());
  }

  Future<String> _getInvitationLink() async {
    final username = tokenService.username;
    final invitationToken = await friendService.createFriendAddToken();
    return 'https://movemo.re/$username/$invitationToken';
  }

  Future<bool> _appWasOpenedBefore() async {
    if (_isFirstAppOpening == false) {
      return true;
    }

    final appWasOpenedBefore = await storage.read(key: kStorageKeyAppWasOpenedBefore);
    _isFirstAppOpening = appWasOpenedBefore != 'true';
    return !_isFirstAppOpening!;
  }

  Future<void> _setAppWasOpened() {
    return storage.write(key: kStorageKeyAppWasOpenedBefore, value: 'true');
  }

  Future<String?> _readInvitationCode() async {
    if (Platform.isAndroid) {
      return _readInvitationCodeOnAndroid();
    }
    return null;
  }

  Future<String?> _readInvitationCodeOnAndroid() async {
    try {
      ReferrerDetails referrer = await AndroidPlayInstallReferrer.installReferrer;
      final referrerUrl = referrer.installReferrer;
      if (referrerUrl == null) {
        return null;
      }
      final referrerData = referrerUrl.split('&').map((referrerParam) => referrerParam.split('='));
      final utmContent = referrerData.firstWhere((referrerParam) => referrerParam[0] == 'utm_content', orElse: () => []);
      if (utmContent.length != 2) {
        return null;
      }
      return utmContent[1];
    } catch (e) {
      return null;
    }
  }
}
