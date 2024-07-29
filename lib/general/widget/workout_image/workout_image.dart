import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:movemore/general/theme/color_theme.dart';

class WorkoutImage extends StatelessWidget {
  const WorkoutImage({super.key, required this.workoutImagePath, this.aspectRatio = 16 / 9});

  final String workoutImagePath;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Container(
        width: constraints.maxWidth,
        height: constraints.maxWidth / aspectRatio,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: MMColorTheme.cardBackground,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Align(
          alignment: Alignment.center,
          child: CachedNetworkImage(
            imageUrl: workoutImagePath,
          ),
        ),
      );
    });
  }
}
