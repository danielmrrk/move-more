import 'dart:math';

import 'package:flutter/material.dart';
import 'package:movemore/general/theme/color_theme.dart';

export 'package:flutter/services.dart' show SmartDashesType, SmartQuotesType, TextCapitalization, TextInputAction, TextInputType;

class RecoveryCodeField extends StatefulWidget {
  const RecoveryCodeField({
    super.key,
    this.focusNode,
    this.onChanged,
    this.onEditingComplete,
    this.onSubmitted,
    this.autofocus = false,
  });

  final bool autofocus;

  final FocusNode? focusNode;

  final ValueChanged<String>? onChanged;

  final VoidCallback? onEditingComplete;

  final ValueChanged<String>? onSubmitted;

  @override
  State<RecoveryCodeField> createState() => _TextFieldState();
}

/// this invisibleChar is the unicode zero width character.
/// We use it because on iOS there is no API that allows to execute a function when the backspace key is pressed.
/// Therefore, by default we prefill any textfield in this widget with an invisible char. When the input seems empty
/// to the user, it is actually filled with the invisible char. So if he hits backspace, the invisible char gets deleted
/// and thus an onChanged event is emitted.
/// If the value of the text field is empty after the onChanged event, we now that the user hit backspace. We then refill the input
/// with the invisible char and proceed handling the backspace event.
const String invisibleChar = '\u200B';

class _TextFieldState extends State<RecoveryCodeField> {
  int _currentIndex = 0;
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());

  @override
  void initState() {
    super.initState();
    for (var controller in _controllers) {
      controller.text = invisibleChar;
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    List<Widget> inputElementsWithSpacing = [];
    for (int index = 0; index < 6; index++) {
      final fieldIsEmpty = _controllers[index].text == invisibleChar;
      inputElementsWithSpacing.add(Expanded(
        child: TextField(
          onChanged: (value) => _handleKeyPressed(value, index),
          keyboardType: TextInputType.number,
          focusNode: _focusNodes[index],
          autofocus: widget.autofocus && index == 0,
          maxLength: 2,
          controller: _controllers[index],
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
          cursorColor: fieldIsEmpty ? theme.colorScheme.onBackground : theme.colorScheme.onPrimary,
          decoration: InputDecoration(
            fillColor: fieldIsEmpty ? MMColorTheme.blue800 : Theme.of(context).colorScheme.primary,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            counterText: '',
            contentPadding: const EdgeInsets.symmetric(vertical: 20),
          ),
        ),
      ));
      if (index < 5) {
        inputElementsWithSpacing.add(const SizedBox(width: 12));
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: inputElementsWithSpacing,
    );
  }

  _handleKeyPressed(String value, int codeInputIndex) {
    if (value.isEmpty) {
      setState(() {
        _controllers[_currentIndex].text = invisibleChar;
        _currentIndex = max(0, codeInputIndex - 1);
        _controllers[_currentIndex].text = invisibleChar;
      });
      _focusNodes[_currentIndex].requestFocus();
    } else {
      final codeDigit = int.tryParse(value.replaceAll(invisibleChar, ''));
      if (codeDigit == null) {
        setState(() {
          _controllers[codeInputIndex].text = invisibleChar;
        });
        return;
      }
      _handleCodeDigitTyped(codeDigit, codeInputIndex);
    }
  }

  _handleCodeDigitTyped(int digit, int codeInputIndex) {
    setState(() {
      _controllers[codeInputIndex].text = invisibleChar + digit.toString();
      _currentIndex = min(5, codeInputIndex + 1);
    });
    _focusNodes[_currentIndex].requestFocus();

    if (widget.onEditingComplete != null && codeInputIndex == 5) {
      widget.onEditingComplete!();
    }

    if (widget.onChanged != null) {
      final String assembledCode =
          _controllers.map((controller) => controller.text).where((digit) => digit != '').join().replaceAll(invisibleChar, '');
      widget.onChanged!(assembledCode);
    }
  }
}
