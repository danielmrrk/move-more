import 'dart:math';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:movemore/general/exercise/exercise.dart';
import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/exercise/exercise_selection_carousel/workout_caption.dart';
import 'package:movemore/general/widget/workout_image/workout_image.dart';
import 'package:movemore/general/widget/workout_image/workout_image_placeholder.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class AnimateableExerciseSelectionCarousel extends StatefulWidget {
  AnimateableExerciseSelectionCarousel({
    super.key,
    this.dotIndicatorDistanceAbove = 12.0,
    this.dotIndicatorDistanceBelow = 12.0,
    this.dotIndicatorHeight = 10.4,
    required this.expandedHeight,
    required this.collapsedHeight,
    required this.exercises,
    required this.exerciseIndex,
    this.onExerciseSelected,
  });

  final double dotIndicatorHeight;
  final double dotIndicatorDistanceAbove;
  final double dotIndicatorDistanceBelow;
  final double expandedHeight;
  final double collapsedHeight;
  int exerciseIndex;
  final List<Exercise> exercises;
  final void Function(Exercise)? onExerciseSelected;

  @override
  State<AnimateableExerciseSelectionCarousel> createState() => _AnimateableExerciseSelectionCarouselState();
}

class _AnimateableExerciseSelectionCarouselState extends State<AnimateableExerciseSelectionCarousel> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final topSafeArea = MediaQuery.of(context).viewPadding.top;

      final scrollableHeight = widget.expandedHeight - widget.collapsedHeight;
      final scrolledPixels = (scrollableHeight - (constraints.maxHeight - widget.collapsedHeight)).round();
      final scrollProgress = scrolledPixels / scrollableHeight;

      final dotOpacity = max(0.0, min(1.0, 1 - scrollProgress * 2));
      final dotSpace = widget.dotIndicatorDistanceAbove + widget.dotIndicatorHeight + widget.dotIndicatorDistanceBelow;

      final dotBottomDistance =
          (widget.dotIndicatorDistanceAbove + widget.dotIndicatorHeight) * scrollProgress + widget.dotIndicatorDistanceBelow;
      final captionBottomDistance = (dotSpace * (1 - scrollProgress)).floorToDouble();
      final offsetNeededToHideCarousel = topSafeArea + widget.collapsedHeight;
      final carouselBottomFactor = scrollProgress < 0.5 ? 0.0 : (scrollProgress - 0.5) * 2;
      final carouselBottomDistance = dotSpace + offsetNeededToHideCarousel * carouselBottomFactor;

      if (widget.exercises.isEmpty) {
        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              width: constraints.maxWidth,
              bottom: carouselBottomDistance,
              child: const WorkoutImagePlaceholder(),
            ),
          ],
        );
      }

      return Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Positioned(
            width: constraints.maxWidth,
            bottom: carouselBottomDistance,
            child: CarouselSlider.builder(
              itemCount: widget.exercises.length,
              itemBuilder: ((context, index, realIndex) {
                final exercise = widget.exercises[index];
                if (index == widget.exerciseIndex) {
                  return Hero(
                    tag: 'hero-current-workout-image',
                    child: WorkoutImage(workoutImagePath: exercise.imageUrl),
                  );
                }
                return WorkoutImage(workoutImagePath: exercise.imageUrl);
              }),
              options: CarouselOptions(
                initialPage: widget.exerciseIndex,
                enlargeCenterPage: true,
                aspectRatio: 16 / 9,
                viewportFraction: 1,
                enlargeFactor: 0.45,
                onPageChanged: _onPageChanged,
              ),
            ),
          ),
          Positioned(
            bottom: captionBottomDistance,
            width: constraints.maxWidth,
            child: Center(
              child: Hero(
                tag: 'hero-current-workout-caption',
                child: WorkoutCaption(
                  title: widget.exercises[widget.exerciseIndex].name.toUpperCase(),
                  sizeFactor: scrollProgress,
                  topSafeSpaceExtend: carouselBottomFactor,
                  maxHeight: widget.collapsedHeight + carouselBottomFactor,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: dotBottomDistance,
            child: Opacity(
              opacity: dotOpacity,
              child: buildDotIndicator(),
            ),
          ),
        ],
      );
    });
  }

  Widget buildDotIndicator() => AnimatedSmoothIndicator(
        activeIndex: widget.exerciseIndex,
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
      widget.exerciseIndex = newIndex;
      if (widget.onExerciseSelected != null) {
        widget.onExerciseSelected!(widget.exercises[newIndex]);
      }
    });
  }
}
