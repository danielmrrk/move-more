import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:movemore/general/timeframe/timeframe.dart';
import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/theme/controls_theme.dart';

class TimeframeSelectionBar<T extends Timeframe> extends StatefulWidget {
  final List<T> timeframes;
  final void Function(T) onTimeFrameSelected;

  const TimeframeSelectionBar({
    super.key,
    required this.timeframes,
    required this.onTimeFrameSelected,
  });

  @override
  State<TimeframeSelectionBar> createState() => _TimeframeSelectionBarState();
}

class _TimeframeSelectionBarState extends State<TimeframeSelectionBar> {
  int _currentTimeframeIndex = 1; // this widget index has to start at 1

  @override
  Widget build(BuildContext context) {
    Map<int, Widget> selectionKnobs = {};
    for (int i = 1; i <= widget.timeframes.length; i++) {
      selectionKnobs[i] = Text(
        widget.timeframes[i - 1].displayName,
        style: MMSegmentTheme(isActive: _currentTimeframeIndex == i).slidingColor,
        overflow: TextOverflow.ellipsis,
      );
    }
    return CustomSlidingSegmentedControl<int>(
      innerPadding: const EdgeInsets.all(4),
      initialValue: 1,
      children: selectionKnobs,
      decoration: BoxDecoration(
        color: MMColorTheme.blue800,
        borderRadius: BorderRadius.circular(40),
      ),
      thumbDecoration: BoxDecoration(
        color: Theme.of(context).colorScheme.background,
        borderRadius: BorderRadius.circular(20),
      ),
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInToLinear,
      onValueChanged: (newIndex) {
        setState(() {
          _currentTimeframeIndex = newIndex;
        });
        widget.onTimeFrameSelected(widget.timeframes[newIndex - 1]);
      },
      fixedWidth: 0.28 * MediaQuery.of(context).size.width,
    );
  }
}
