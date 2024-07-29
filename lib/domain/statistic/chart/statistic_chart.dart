import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:movemore/domain/statistic/chart/chart_time_beam.dart';
import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/theme/text_style_theme.dart';

const kConcurrentDataPointsVisible = 8;
const kCacheAmount = 5;

class StatisticChart extends StatefulWidget {
  final double xOffset;
  final ChartTimeBeam timebeam;
  const StatisticChart({
    super.key,
    required this.timebeam,
    this.xOffset = 0,
  });

  @override
  State<StatisticChart> createState() => _StatisticChartState();
}

class _StatisticChartState extends State<StatisticChart> {
  int get maxDataPointIndex => kConcurrentDataPointsVisible + widget.xOffset.floor() + kCacheAmount;
  int getXValueForDataPointIndex(int dataPointIndex) => (-1 * dataPointIndex) + kConcurrentDataPointsVisible;

  @override
  Widget build(BuildContext context) {
    List<LineChartBarData> lines = [];
    lines = _createLines();

    return LineChart(LineChartData(
      minX: 0 - widget.xOffset,
      maxX: kConcurrentDataPointsVisible - widget.xOffset,
      maxY: max(10.0, widget.timebeam.getMaxY()),
      lineTouchData: LineTouchData(
        getTouchedSpotIndicator: _getTouchedSpotIndicator,
        touchTooltipData: _getTooltipData(),
      ),
      borderData: FlBorderData(show: false),
      lineBarsData: lines,
      gridData: FlGridData(
        getDrawingHorizontalLine: (value) {
          return const FlLine(color: MMColorTheme.neutral600, strokeWidth: 0.5);
        },
        getDrawingVerticalLine: (value) => const FlLine(color: MMColorTheme.neutral600, strokeWidth: 0.5),
      ),
      titlesData: _createAxisTitlesData(),
    ));
  }

  List<LineChartBarData> _createLines() {
    return [
      _createDateLine(),
      ..._createUserLines(),
    ];
  }

  LineChartBarData _createDateLine() {
    return LineChartBarData(
      spots: _createDateLineDataPoints(),
      color: Colors.transparent,
    );
  }

  List<FlSpot> _createDateLineDataPoints() {
    List<FlSpot> spots = [];
    for (int x = 0; x < maxDataPointIndex; x++) {
      var spot = FlSpot(
        getXValueForDataPointIndex(x).toDouble(),
        0.0,
      );
      spots.add(spot);
    }
    return spots;
  }

  List<LineChartBarData> _createUserLines() {
    List<LineChartBarData> lines = [];
    for (var userId in widget.timebeam.getUserIds()) {
      final userLine = LineChartBarData(
        spots: _createUserLineDataPoints(userId),
        barWidth: 4,
        isStrokeCapRound: true,
        isStrokeJoinRound: true,
        color: widget.timebeam.getUserColor(userId),
        dotData: FlDotData(
          getDotPainter: _getHollowCirclePainter,
        ),
      );
      lines.add(userLine);
    }
    return lines;
  }

  List<FlSpot> _createUserLineDataPoints(int userId) {
    List<FlSpot> spots = [];
    for (int x = 0; x < maxDataPointIndex; x++) {
      var spot = FlSpot(
        getXValueForDataPointIndex(x).toDouble(),
        widget.timebeam.getScoreAt(x, userId).toDouble(),
      );
      spots.add(spot);
    }
    return spots;
  }

  LineTouchTooltipData _getTooltipData() {
    return LineTouchTooltipData(
      fitInsideVertically: true,
      tooltipBgColor: MMColorTheme.blue800,
      tooltipBorder: BorderSide(color: MMColorTheme.secondary),
      getTooltipItems: (touchedSpots) {
        final dateTooltipItem = LineTooltipItem(
          widget.timebeam.getDateAt((kConcurrentDataPointsVisible - touchedSpots[0].x).round()),
          MMTextStyleTheme.standardSmallSemiBold,
        );

        final toolTips = [
          dateTooltipItem,
          ..._getUserScoreTooltips(touchedSpots),
        ];

        return toolTips;
      },
    );
  }

  List<LineTooltipItem> _getUserScoreTooltips(List<LineBarSpot> touchedSpots) {
    final List<LineTooltipItem> toolTips = [];
    final userIds = widget.timebeam.getUserIds().toList();
    for (int i = 0; i < userIds.length; i++) {
      final x = touchedSpots[i].x.toInt();
      final dataPointIndex = getXValueForDataPointIndex(x);
      final scoreTooltipItem = LineTooltipItem(
        widget.timebeam.getScoreAt(dataPointIndex, userIds[i]).toString(),
        MMTextStyleTheme.standardSmall.copyWith(
          color: widget.timebeam.getUserColor(userIds[i]),
        ),
      );
      toolTips.add(scoreTooltipItem);
    }
    return toolTips;
  }

  List<TouchedSpotIndicatorData?> _getTouchedSpotIndicator(barData, spotIndexes) {
    return [
      for (int i = 0; i < barData.showingIndicators.length; i++)
        TouchedSpotIndicatorData(
          const FlLine(color: MMColorTheme.neutral300, strokeWidth: 1, dashArray: [5, 5]),
          FlDotData(show: true, getDotPainter: _getFilledCirclePainter),
        ),
    ];
  }

  FlDotCirclePainter _getHollowCirclePainter(spot, xPercentage, LineChartBarData bar, index) {
    return FlDotCirclePainter(
      radius: 4.5,
      color: MMColorTheme.blue800,
      strokeColor: bar.color!,
      strokeWidth: 4,
    );
  }

  FlDotCirclePainter _getFilledCirclePainter(spot, xPercentage, LineChartBarData bar, index) {
    return FlDotCirclePainter(
      radius: 0,
      color: MMColorTheme.blue800,
      strokeColor: bar.color!,
      strokeWidth: 6,
    );
  }

  FlTitlesData _createAxisTitlesData() {
    return FlTitlesData(
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        drawBelowEverything: false,
        sideTitles: SideTitles(
          reservedSize: 1,
          showTitles: true,
          getTitlesWidget: (y, meta) {
            if (y % meta.appliedInterval != 0) {
              return const Text('');
            }
            return Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
              child: Text(
                y.floor().toString(),
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
                textAlign: TextAlign.end,
                style: MMTextStyleTheme.standardSmall,
              ),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          getTitlesWidget: (value, meta) {
            if (value.truncate() != value) {
              return const SizedBox();
            }
            return Container(
              height: 100,
              alignment: Alignment.bottomCenter,
              child: Transform.translate(
                offset: const Offset(0, 10),
                child: Text(
                  widget.timebeam.getXLabel((kConcurrentDataPointsVisible - value).round()),
                  textAlign: TextAlign.end,
                  style: MMTextStyleTheme.standardSmall,
                  overflow: TextOverflow.visible,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
