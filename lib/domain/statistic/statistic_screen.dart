import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemore/domain/auth/token_service.dart';
import 'package:movemore/domain/statistic/chart/statistic_chart.dart';
import 'package:movemore/domain/statistic/chart/chart_time_beam.dart';
import 'package:movemore/domain/statistic/chart/user_legend.dart';
import 'package:movemore/general/model/user.dart';
import 'package:movemore/general/timeframe/timeframe.dart';
import 'package:movemore/general/timeframe/timeframe_selection_bar.dart';

const double kStartXOffset = -3;

class StatisticScreen extends ConsumerStatefulWidget {
  final int exerciseId;
  final User friend;
  const StatisticScreen({super.key, required this.exerciseId, required this.friend});

  @override
  ConsumerState<StatisticScreen> createState() => _StatisticScreenState();
}

class _StatisticScreenState extends ConsumerState<StatisticScreen> with SingleTickerProviderStateMixin {
  StatisticTimeframe _timeframe = StatisticTimeframe.day;
  late ChartTimeBeam chartData;
  late User self;

  double xOffset = kStartXOffset;
  double velocity = 0.0;
  double damping = 0.90;
  late AnimationController inertiaScrollingController;

  @override
  void initState() {
    super.initState();

    inertiaScrollingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    final tokenData = tokenService.token!;
    self = User(userId: tokenData.userId, username: tokenData.username);

    _createChartData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.friend.username),
      ),
      body: Container(
        clipBehavior: Clip.hardEdge,
        decoration: const BoxDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TimeframeSelectionBar(
              timeframes: StatisticTimeframe.values,
              onTimeFrameSelected: _onTimeFrameChanged,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GestureDetector(
                onHorizontalDragUpdate: _onSwipeUpdate,
                onHorizontalDragEnd: _onSwipeEnd,
                child: StatisticChart(
                  timebeam: chartData,
                  xOffset: xOffset,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: UserLegend(
                users: [self, if (widget.friend.userId != self.userId) widget.friend],
                timebeam: chartData,
              ),
            ),
            const SizedBox(height: 128),
          ],
        ),
      ),
    );
  }

  void _createChartData() {
    chartData = ChartTimeBeam(
      timeframe: _timeframe,
      exerciseId: widget.exerciseId,
      onHasNewData: _onHasNewData,
      comparedUserId: widget.friend.userId,
    );
  }

  void _onTimeFrameChanged(covariant StatisticTimeframe timeframe) {
    setState(() {
      _timeframe = timeframe;
      xOffset = kStartXOffset;
      _createChartData();
    });
  }

  void _onSwipeUpdate(DragUpdateDetails details) {
    _adjustXOffset(details.delta.dx);
  }

  void _onSwipeEnd(DragEndDetails details) {
    inertiaScrollingController.reset();
    if (xOffset < kStartXOffset) {
      velocity = (kStartXOffset - xOffset).abs() * (1 / damping) * 30;
    } else {
      velocity = details.velocity.pixelsPerSecond.dx;
    }
    _startInertiaScrollAnimation();
  }

  void _startInertiaScrollAnimation() {
    inertiaScrollingController.reset();
    inertiaScrollingController.addListener(() {
      velocity *= damping;
      _adjustXOffset(velocity / 30);
    });
    inertiaScrollingController.forward();
  }

  void _adjustXOffset(double screenOffset) {
    var chartOffset = _screenToChartOffset(screenOffset);
    setState(() {
      xOffset = xOffset + chartOffset;
      if (xOffset < kStartXOffset) {
        velocity = (kStartXOffset - xOffset).abs() * (1 / damping) * 30;
      }
    });
  }

  double _screenToChartOffset(double screenOffset) {
    final deviceWidth = MediaQuery.of(context).size.width;
    return kConcurrentDataPointsVisible * (screenOffset / deviceWidth);
  }

  void _onHasNewData() => setState(() {});
}
