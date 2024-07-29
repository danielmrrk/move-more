import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemore/general/exercise/exercise.dart';
import 'package:movemore/domain/training/perform_exercise_screen.dart';
import 'package:movemore/domain/training/instruction_service.dart';
import 'package:movemore/general/theme/controls_theme.dart';
import 'package:movemore/general/theme/text_style_theme.dart';
import 'package:movemore/general/util/navigation.dart';
import 'package:movemore/general/widget/custom_checkbox.dart';
import 'package:movemore/domain/training/training_frame.dart';

class InstructionScreen extends ConsumerStatefulWidget {
  const InstructionScreen({
    super.key,
    required this.selectedExercise,
    this.showDisableInstructionScreenOption = true,
  });

  final Exercise selectedExercise;
  final bool showDisableInstructionScreenOption;

  @override
  ConsumerState<InstructionScreen> createState() => _InstructionScreenState();
}

class _InstructionScreenState extends ConsumerState<InstructionScreen> {
  bool _hideScreen = false;
  @override
  Widget build(BuildContext context) {
    return TrainingFrame(
      exerciseName: widget.selectedExercise.name,
      exerciseImagePath: widget.selectedExercise.imageUrl,
      child: Column(children: [
        const SizedBox(
          height: 32,
        ),
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            children: [
              TextSpan(text: 'Now do your ', style: MMTextStyleTheme.standardExtraLarge),
              TextSpan(text: '${widget.selectedExercise.name}\'s\n', style: MMTextStyleTheme.standardExtraLargeBold),
              TextSpan(
                text: 'and count them.',
                style: MMTextStyleTheme.standardExtraLarge,
              ),
            ],
          ),
        ),
        const SizedBox(height: 116),
        Hero(
          tag: 'main-cta-button',
          child: FilledButton(
            onPressed: () {
              instructionScreenService.setShowInstructionScreen(!_hideScreen);
              navigateTo(
                  PerformExerciseScreen(
                    selectedExercise: widget.selectedExercise,
                  ),
                  context);
            },
            style: MMButtonTheme.standardButtonStyle,
            child: const Text('NEXT'),
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        if (widget.showDisableInstructionScreenOption)
          CustomCheckbox(
            label: 'Do not show this page again',
            onValueChanged: setShowInstructionScreen,
          ),
      ]),
    );
  }

  void setShowInstructionScreen(bool hideScreen) {
    setState(() {
      _hideScreen = hideScreen;
    });
  }
}
