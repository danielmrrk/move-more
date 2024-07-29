import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movemore/general/exercise/exercise.dart';
import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/exercise/exercise_selection_carousel/workout_caption.dart';
import 'package:movemore/general/widget/workout_image/workout_image.dart';
import 'package:movemore/general/widget/workout_image/workout_image_placeholder.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class ExerciseSelectionCarousel extends StatefulWidget {
  const ExerciseSelectionCarousel({
    super.key,
    required this.exercises,
    this.onExerciseSelected,
  });

  final List<Exercise> exercises;
  final void Function(Exercise)? onExerciseSelected;

  @override
  State<ExerciseSelectionCarousel> createState() => _ExerciseSelectionCarouselState();
}

class _ExerciseSelectionCarouselState extends State<ExerciseSelectionCarousel> {
  int _selectedExerciseIndex = 0;

  @override
  Widget build(BuildContext context) {
    if (widget.exercises.isEmpty) {
      return const WorkoutImagePlaceholder();
    }

    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              child: CarouselSlider.builder(
                itemCount: widget.exercises.length,
                itemBuilder: ((context, index, realIndex) {
                  final exercise = widget.exercises[index];
                  if (index == _selectedExerciseIndex) {
                    return Hero(
                      tag: 'hero-current-workout-image',
                      child: WorkoutImage(workoutImagePath: exercise.imageUrl),
                    );
                  }
                  return WorkoutImage(workoutImagePath: exercise.imageUrl);
                }),
                options: CarouselOptions(
                  initialPage: _selectedExerciseIndex,
                  enlargeCenterPage: true,
                  aspectRatio: 16 / 9,
                  viewportFraction: 1,
                  enlargeFactor: 0.45,
                  onPageChanged: _onPageChanged,
                ),
              ),
            ),
            Center(
              child: Hero(
                tag: 'hero-current-workout-caption',
                child: WorkoutCaption(
                  title: widget.exercises[_selectedExerciseIndex].name.toUpperCase(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        buildDotIndicator(),
      ],
    );
  }

  Widget buildDotIndicator() => AnimatedSmoothIndicator(
        activeIndex: _selectedExerciseIndex,
        count: widget.exercises.length,
        effect: const ScrollingDotsEffect(
          activeDotColor: MMColorTheme.segmentTextColor,
          dotColor: MMColorTheme.neutral100,
          dotHeight: 8,
          dotWidth: 8,
        ),
      );

  _onPageChanged(int newIndex, reason) {
    setState(() {
      _selectedExerciseIndex = newIndex;
      if (widget.onExerciseSelected != null) {
        widget.onExerciseSelected!(widget.exercises[newIndex]);
      }
    });
  }
}
