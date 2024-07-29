abstract class Timeframe {
  final String technicalName;
  final String displayName;
  static final List<Timeframe> values = [];
  const Timeframe._(this.technicalName, this.displayName);
}

class StatisticTimeframe extends Timeframe {
  static const day = StatisticTimeframe._('day', 'Daily', 1);
  static const week = StatisticTimeframe._('week', 'Weekly', 7);
  static const month = StatisticTimeframe._('month', 'Monthly', 30);
  static final List<StatisticTimeframe> values = [day, week, month];

  final int avgDaysValue;

  const StatisticTimeframe._(String technicalName, String displayName, this.avgDaysValue) : super._(technicalName, displayName);

  @override
  String toString() {
    return technicalName;
  }
}

class RankingTimeframe extends Timeframe {
  static const days1 = RankingTimeframe._('1day', 'Today');
  static const days7 = RankingTimeframe._('7days', '7 Days');
  static const days30 = RankingTimeframe._('30days', '30 Days');
  static final List<RankingTimeframe> values = [days1, days7, days30];

  const RankingTimeframe._(String technicalName, String displayName) : super._(technicalName, displayName);

  @override
  String toString() {
    return technicalName;
  }
}
