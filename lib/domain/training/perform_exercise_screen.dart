import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/general/exercise/exercise.dart';
import 'package:movemore/domain/ranking/main_screen.dart';
import 'package:movemore/general/exercise/exercise_service.dart';
import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/theme/controls_theme.dart';
import 'package:movemore/general/util/navigation.dart';
import 'package:movemore/general/util/snackbar.dart';
import 'package:movemore/domain/training/training_frame.dart';
import 'package:movemore/general/widget/custom_number_picker.dart';

class PerformExerciseScreen extends ConsumerStatefulWidget {
  const PerformExerciseScreen({
    super.key,
    required this.selectedExercise,
  });

  final Exercise selectedExercise;

  @override
  ConsumerState<PerformExerciseScreen> createState() => _PerformExerciseScreenState();
}

class _PerformExerciseScreenState extends ConsumerState<PerformExerciseScreen> {
  int _performedRepetitions = 0; // int the future last Value
  final edgeNumberStyle = GoogleFonts.inter(color: MMColorTheme.neutral400, fontSize: 14, fontWeight: FontWeight.w500);
  final edgeCenterNumberStyle = GoogleFonts.inter(color: MMColorTheme.neutral300, fontSize: 18, fontWeight: FontWeight.w500);

  @override
  Widget build(BuildContext context) {
    const lenseBorderWidth = 4.0;
    return TrainingFrame(
      exerciseName: widget.selectedExercise.name,
      exerciseImagePath: widget.selectedExercise.imageUrl,
      child: Column(
        children: [
          const SizedBox(
            height: 64,
          ),
          const Text(
            'I DID',
            style: TextStyle(fontFamily: 'roboto', fontSize: 20, fontWeight: FontWeight.w700),
            textAlign: TextAlign.center,
          ),
          Container(
            alignment: Alignment.center,
            height: 64,
            decoration: BoxDecoration(color: MMColorTheme.blue800, borderRadius: BorderRadius.circular(200)),
            margin: const EdgeInsets.symmetric(horizontal: 24),
            width: double.infinity,
            child: CustomNumberPicker(
              haptics: true,
              axis: Axis.horizontal,
              itemCount: 5,
              step: 1,
              edgeTextStyle: GoogleFonts.inter(color: MMColorTheme.neutral400, fontSize: 14, fontWeight: FontWeight.w500),
              centerTextStyle: GoogleFonts.inter(color: MMColorTheme.neutral300, fontSize: 18, fontWeight: FontWeight.w500),
              selectedTextStyle: GoogleFonts.inter(color: MMColorTheme.neutral100, fontSize: 20, fontWeight: FontWeight.w500),
              decoration: const BoxDecoration(
                shape: BoxShape.rectangle,
                border: Border.symmetric(
                  vertical: BorderSide(color: MMColorTheme.iconColor, width: lenseBorderWidth),
                ),
              ),
              itemWidth: 62,
              lenseWidth: 62 + 2 * lenseBorderWidth,
              minValue: 0,
              maxValue: 9999,
              value: _performedRepetitions,
              onChanged: ((value) {
                setState(() {
                  _performedRepetitions = value;
                });
              }),
            ),
          ),
          const SizedBox(
            height: 48,
          ),
          FilledButton(
            onPressed: () {
              HapticFeedback.heavyImpact();
              _submitPerformedExercise();
            },
            style: MMButtonTheme.standardButtonStyle,
            child: const Text('CONFIRM'),
          ),
        ],
      ),
    );
  }

  _submitPerformedExercise() async {
    try {
      if (_performedRepetitions > 0) {
        await exerciseService.train(widget.selectedExercise.id, _performedRepetitions);
      }
      if (context.mounted) {
        navigateTo(
          MainScreen(
            selectedExerciseId: widget.selectedExercise.id,
          ),
          context,
          removeHistory: true,
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        showApiException(e, context);
      }
    }
  }
}
