import 'package:flutter/material.dart';
import 'package:movemore/general/theme/color_theme.dart';

class WorkoutImagePlaceholder extends StatelessWidget {
  const WorkoutImagePlaceholder({super.key, this.aspectRatio = 16 / 9});

  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Opacity(
        opacity: 0.5,
        child: Container(
          width: constraints.maxWidth,
          height: constraints.maxWidth / aspectRatio,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: MMColorTheme.cardBackground,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Align(
              alignment: Alignment.center,
              child: CircularProgressIndicator.adaptive(
                semanticsLabel: 'Loading exercises',
              )),
        ),
      );
    });
  }
}
