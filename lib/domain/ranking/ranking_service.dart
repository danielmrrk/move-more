import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:movemore/domain/ranking/ranking.dart';
import 'package:movemore/general/timeframe/timeframe.dart';
import 'package:movemore/domain/network/dio_provider.dart';

const storage = FlutterSecureStorage(
  aOptions: AndroidOptions(
    encryptedSharedPreferences: true,
  ),
);

const String kRankedUsersKey = 'ranked_users';
const String kRecentRankingOrderKey = "recent_ranking_order";
const String kBeforeRecentRankingOrderKey = "before_recent_ranking_order";
const String kRankingDateKey = 'recent_ranking_date';

final rankingService = RankingService();

class RankingService {
  Future<List<RankedUser>> getRankedUserList(int exerciseId, RankingTimeframe timeframe) async {
    final Response<List<dynamic>> rankingResponse = await dio.get('/ranking/friends/$exerciseId/${timeframe.technicalName}');
    final currentRanking = rankingResponse.data!.map((rankedUser) => RankedUser.fromJson(rankedUser)).toList();

    await maybeReset(exerciseId, timeframe);
    await _maybeUpdateChangedRanking(currentRanking, exerciseId, timeframe);

    return currentRanking;
  }

  String getLastChangeKey(int exerciseId, RankingTimeframe timeframe) {
    return "$kRankedUsersKey/$exerciseId/$timeframe/$kRecentRankingOrderKey";
  }

  String getBeforeLastChangeKey(int exerciseId, RankingTimeframe timeframe) {
    return "$kRankedUsersKey/$exerciseId/$timeframe/$kBeforeRecentRankingOrderKey";
  }

  String getRankingDateKey(int exerciseId, RankingTimeframe timeframe) {
    return "$kRankedUsersKey/$exerciseId/$timeframe/$kRankingDateKey";
  }

  String formatRankedDate(DateTime rankedDate) {
    if (!rankedDate.isUtc) {
      rankedDate = rankedDate.toUtc();
    }
    return DateFormat('dd/MM/y').format(rankedDate);
  }

  // note: in germany UTC+2 therefore update only at 2am
  Future<void> maybeReset(int exerciseId, RankingTimeframe timeframe) async {
    if (timeframe == RankingTimeframe.days1) {
      final String lastChangeKey = getLastChangeKey(exerciseId, timeframe);
      final String beforeLastChangeKey = getBeforeLastChangeKey(exerciseId, timeframe);
      final String rankingDateKey = getRankingDateKey(exerciseId, timeframe);
      DateTime newUTCDateTime = DateTime.now().toUtc();
      String newUTCDate = formatRankedDate(newUTCDateTime);
      final String? lastUTCDate = await storage.read(key: rankingDateKey);
      if (lastUTCDate == null) {
        storage.write(key: rankingDateKey, value: newUTCDate);
      } else if (newUTCDate != lastUTCDate) {
        storage.write(key: rankingDateKey, value: newUTCDate);
        storage.delete(key: lastChangeKey);
        storage.delete(key: beforeLastChangeKey);
      }
    }
  }

  Future<List<int>> getRankOrderBeforeLastChange(int exerciseId, RankingTimeframe timeframe) async {
    final String key = getBeforeLastChangeKey(exerciseId, timeframe);
    var result = await storage.read(key: key);
    if (result == null) {
      return [];
    }
    final beforeLastChange = json.decode(result).cast<int>();
    return beforeLastChange;
  }

  Future<void> _maybeUpdateChangedRanking(List<RankedUser> currentRanking, int exerciseId, RankingTimeframe timeframe) async {
    final lastChange = await _getRankOrderAfterLastChange(exerciseId, timeframe);
    final currentRankingUserIds = currentRanking.map((rankedUser) => rankedUser.userId).toList();

    bool rankingDiffers = !listEquals(lastChange, currentRankingUserIds);
    if (rankingDiffers) {
      await _updateLastState(exerciseId, timeframe, currentRankingUserIds);
      await _updateBeforeLastState(exerciseId, timeframe, lastChange);
    }
  }

  Future<List<int>> _getRankOrderAfterLastChange(int exerciseId, RankingTimeframe timeframe) async {
    final String key = getLastChangeKey(exerciseId, timeframe);
    var result = await storage.read(key: key);
    if (result == null) {
      return [];
    }
    final lastChange = json.decode(result).cast<int>();
    return lastChange;
  }

  Future<void> _updateLastState(int exerciseId, RankingTimeframe timeframe, List<int> rankedUserIds) async {
    final key = getLastChangeKey(exerciseId, timeframe);
    final String encodedRankedUserIds = json.encode(rankedUserIds);
    await storage.write(key: key, value: encodedRankedUserIds);
  }

  Future<void> _updateBeforeLastState(int exerciseId, RankingTimeframe timeframe, List<int> previousState) async {
    final key = getBeforeLastChangeKey(exerciseId, timeframe);
    final String rankedUserIds = json.encode(previousState);
    await storage.write(key: key, value: rankedUserIds);
  }
}
