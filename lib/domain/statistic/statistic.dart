class StatisticPacket {
  int userId;
  List<Statistic> statistics;

  StatisticPacket(this.userId, this.statistics);

  factory StatisticPacket.fromJson(Map<String, dynamic> json) {
    final statistics = (json['statistics'] as List<dynamic>).map((statistic) => Statistic.fromJson(statistic)).toList();
    return StatisticPacket(json['userId'], statistics);
  }
}

class Statistic {
  int score;
  String periodStartDate;

  Statistic(this.score, this.periodStartDate);

  factory Statistic.fromJson(Map<String, dynamic> json) {
    return Statistic(json['score'], json['periodStartDate']);
  }
}
