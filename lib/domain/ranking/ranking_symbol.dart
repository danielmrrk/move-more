class RankingSymbol {
  final String rankSymbol;

  const RankingSymbol._(this.rankSymbol);

  @override
  String toString() {
    return rankSymbol;
  }

  static RankingSymbol fromChange(int lastRank, int currentRank) {
    if (lastRank == currentRank || lastRank == -1) {
      return neutral;
    } else if (lastRank > currentRank) {
      return up;
    } else {
      return down;
    }
  }

  static const up = RankingSymbol._('up');
  static const down = RankingSymbol._('down');
  static const neutral = RankingSymbol._('neutral');
}
