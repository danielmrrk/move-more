import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:movemore/domain/auth/token_service.dart';
import 'package:movemore/domain/statistic/statistic.dart';
import 'package:movemore/domain/statistic/statistic_service.dart';
import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/timeframe/timeframe.dart';

const kStatisticPacketSize = 10;

class ChartTimeBeam {
  final Map<int, Map<int, int>> _userScoreDataPoints;
  final Map<int, Color> _userColors;
  final List<int> _indexesCurrentlyFetching;

  DateTime zero;
  StatisticTimeframe timeframe;
  int exerciseId;
  int comparedUserId;
  void Function() onHasNewData;

  ChartTimeBeam({
    required this.timeframe,
    required this.exerciseId,
    required this.comparedUserId,
    required this.onHasNewData,
  })  : zero = DateTime(DateTime.now().toUtc().year, DateTime.now().toUtc().month, DateTime.now().toUtc().day),
        _userScoreDataPoints = {},
        _userColors = {},
        _indexesCurrentlyFetching = [] {
    _init();
  }

  Color getUserColor(int userId) {
    if (!_userColors.containsKey(userId)) {
      return Colors.transparent;
    }
    return _userColors[userId]!;
  }

  void _init() async {
    await _optimizedFetchIndex(0);
    _createUserColors(getUserIds());
    onHasNewData();
  }

  void _createUserColors(Iterable<int> userIds) {
    int i = 0;
    List<Color> colors = [
      MMColorTheme.primary,
      MMColorTheme.secondary,
    ];
    for (var userId in userIds) {
      _userColors[userId] = colors[i];
      i++;
    }
  }

  Iterable<int> getUserIds() {
    final ownUserId = tokenService.userId;
    if (ownUserId != null && ownUserId != comparedUserId) {
      return [
        ownUserId,
        comparedUserId,
      ];
    }
    return [comparedUserId];
  }

  double getMaxY() {
    int maxValue = 0;
    for (var userScores in _userScoreDataPoints.values) {
      for (var userScore in userScores.values) {
        if (userScore > maxValue) {
          maxValue = userScore;
        }
      }
    }
    return maxValue.toDouble();
  }

  int getScoreAt(int index, int userId) {
    if (_shouldFetchIndex(index)) {
      _optimizedFetchIndex(index);
      return 0;
    }
    if (_isFetching(index) || !_userScoreDataPoints[index]!.containsKey(userId)) {
      return 0;
    }
    return _userScoreDataPoints[index]![userId]!;
  }

  String getDateAt(int dataPointIndex) {
    final targetDate = zero.subtract(Duration(days: dataPointIndex * timeframe.avgDaysValue));
    switch (timeframe) {
      case StatisticTimeframe.day:
        return DateFormat.yMd().format(targetDate);
      case StatisticTimeframe.week:
        int dayOfYear = int.parse(DateFormat('D').format(targetDate));
        int weekNumber = ((dayOfYear - targetDate.weekday + 10) / 7).floor();
        return "${targetDate.year} CW${weekNumber.toString()}";
      case StatisticTimeframe.month:
        return DateFormat(DateFormat.YEAR_MONTH).format(targetDate);
    }
    return 'ERR';
  }

  String getXLabel(int dataPointIndex) {
    final targetDate = zero.subtract(Duration(days: dataPointIndex * timeframe.avgDaysValue));
    switch (timeframe) {
      case StatisticTimeframe.day:
        return DateFormat(DateFormat.ABBR_WEEKDAY).format(targetDate)[0];
      case StatisticTimeframe.week:
        int dayOfYear = int.parse(DateFormat('D').format(targetDate));
        int weekNumber = ((dayOfYear - targetDate.weekday + 10) / 7).floor();
        return weekNumber.toString();
      case StatisticTimeframe.month:
        return DateFormat(DateFormat.ABBR_MONTH).format(targetDate);
    }
    return 'ERR';
  }

  _shouldFetchIndex(int index) {
    return !_hasFetched(index) && !_isFetching(index);
  }

  _hasFetched(int index) {
    return _userScoreDataPoints.containsKey(index);
  }

  _isFetching(int index) {
    return _indexesCurrentlyFetching.contains(index);
  }

  _optimizedFetchIndex(int desiredIndex) async {
    desiredIndex -= 1;
    final desiredDate = _toDateTime(desiredIndex);
    for (int index = desiredIndex; index <= desiredIndex + kStatisticPacketSize; index++) {
      _indexesCurrentlyFetching.add(index);
    }
    final statistic = await _fetchStatistics(firstKnown: desiredIndex == 0 ? null : desiredDate);
    for (int index = desiredIndex; index <= desiredIndex + kStatisticPacketSize; index++) {
      _userScoreDataPoints.putIfAbsent(index, () => ({}));
      _indexesCurrentlyFetching.remove(index);
    }
    _mapStatisticPacketsOnXAxis(statistic, desiredIndex);
    onHasNewData();
  }

  Future<List<StatisticPacket>> _fetchStatistics({DateTime? firstKnown}) async {
    return await statisticService.getStatisticPacket(
      exerciseId: exerciseId,
      timeframe: timeframe,
      comparedUserId: comparedUserId,
      firstKnown: firstKnown,
    );
  }

  void _mapStatisticPacketsOnXAxis(List<StatisticPacket> userStatistics, int desiredIndex) {
    for (var statisticPacket in userStatistics) {
      for (var dataPoint in statisticPacket.statistics) {
        final periodStartDate = DateTime.parse(dataPoint.periodStartDate);
        final dataPointIndex = _toIndex(periodStartDate);
        assert(dataPointIndex >= desiredIndex && dataPointIndex <= desiredIndex + 10);
        _userScoreDataPoints[dataPointIndex]![statisticPacket.userId] = dataPoint.score;
      }
    }
  }

  int _toIndex(DateTime datetime) {
    final utcDate = datetime.toUtc();
    final morning = DateTime(utcDate.year, utcDate.month, utcDate.day);
    final diffInDays = zero.difference(morning).inDays;
    return (diffInDays / timeframe.avgDaysValue).round();
  }

  DateTime _toDateTime(int index) {
    return zero.subtract(Duration(days: (timeframe.avgDaysValue * index).round()));
  }
}
