import 'package:flutter/material.dart';
import 'package:movemore/general/theme/text_style_theme.dart';
import 'package:movemore/general/exercise/exercise_selection_carousel/workout_caption.dart';
import 'package:movemore/general/widget/workout_image/workout_image.dart';

class TrainingFrame extends StatefulWidget {
  const TrainingFrame({
    super.key,
    required this.exerciseName,
    required this.exerciseImagePath,
    required this.child,
  });

  final String exerciseName;
  final String exerciseImagePath;
  final Widget child;

  @override
  State<TrainingFrame> createState() => _TrainingFrameState();
}

class _TrainingFrameState extends State<TrainingFrame> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        widget.exerciseName,
        style: MMTextStyleTheme.standardLarge,
      )),
      body: Column(
        children: [
          Stack(
            alignment: Alignment.bottomCenter,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 100.0),
                child: Hero(
                  tag: 'hero-current-workout-image',
                  child: WorkoutImage(workoutImagePath: widget.exerciseImagePath),
                ),
              ),
              Transform.translate(
                //offset 1px downwards to fix a bug where there was a thin line below the WorkoutCaption on android devices
                offset: const Offset(0, 1),
                child: Hero(
                  tag: 'hero-current-workout-caption',
                  child: WorkoutCaption(
                    title: widget.exerciseName.toUpperCase(),
                  ),
                ),
              ),
            ],
          ),
          widget.child,
        ],
      ),
    );
  }
}
