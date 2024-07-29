import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/general/exercise/exercise_selection_carousel/exercise_selection_carousel.dart';
import 'package:movemore/domain/training/instruction_screen.dart';
import 'package:movemore/general/exercise/exercise.dart';
import 'package:movemore/general/exercise/exercise_service.dart';
import 'package:movemore/general/theme/controls_theme.dart';
import 'package:movemore/general/theme/text_style_theme.dart';
import 'package:movemore/general/util/navigation.dart';
import 'package:movemore/general/util/snackbar.dart';

class ChooseFirstExerciseScreen extends ConsumerStatefulWidget {
  const ChooseFirstExerciseScreen({
    super.key,
  });

  @override
  ConsumerState<ChooseFirstExerciseScreen> createState() => _ChooseFirstExerciseScreenState();
}

class _ChooseFirstExerciseScreenState extends ConsumerState<ChooseFirstExerciseScreen> {
  List<Exercise> _exercises = [];
  Exercise? _selectedExercise;

  @override
  void initState() {
    super.initState();
    _fetchExercises();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Get it started',
          style: MMTextStyleTheme.standardLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(
              height: 64,
            ),
            Text(
              'First, choose your exercise\n to start off with',
              style: MMTextStyleTheme.standardExtraLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ExerciseSelectionCarousel(
              exercises: _exercises,
              onExerciseSelected: (exercise) => _selectedExercise = exercise,
            ),
            const SizedBox(
              height: 108,
            ),
            Hero(
              tag: 'main-cta-button',
              child: FilledButton(
                onPressed: _onProceedWithCurrentExercise,
                style: MMButtonTheme.standardButtonStyle,
                child: const Text('NEXT'),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You can still choose any\n other exercise later.',
              style: MMTextStyleTheme.standardExtraSmallGrey,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _fetchExercises() async {
    try {
      List<Exercise> exercises = await exerciseService.listExercises();
      setState(() {
        _exercises = exercises;
        if (_exercises.isNotEmpty) {
          _selectedExercise = _exercises[0];
        }
      });
    } on ApiException catch (e) {
      if (context.mounted) {
        showApiException(e, context);
      }
    }
  }

  void _onProceedWithCurrentExercise() {
    if (_selectedExercise == null) {
      showVisualFeedbackSnackbar(context, 'Error: No exercises found. Please try again later.');
      return;
    }
    navigateTo(
      InstructionScreen(
        selectedExercise: _selectedExercise!,
        showDisableInstructionScreenOption: false,
      ),
      context,
    );
  }
}
