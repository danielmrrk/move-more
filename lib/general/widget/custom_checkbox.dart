import 'package:flutter/material.dart';
import 'package:movemore/general/theme/color_theme.dart';

class CustomCheckbox extends StatefulWidget {
  const CustomCheckbox({super.key, required this.label, required this.onValueChanged});

  final String label;
  final Function onValueChanged;

  @override
  State<CustomCheckbox> createState() => _CustomCheckboxState();
}

class _CustomCheckboxState extends State<CustomCheckbox> {
  bool checked = false;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () {
            checked = !checked;
            widget.onValueChanged(checked);
          },
          child: Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: const Color(0xff000000), width: 1),
              color: const Color(0xffd9d9d9),
            ),
            child: Center(
              child: checked
                  ? const Icon(
                      Icons.check,
                      color: MMColorTheme.iconColor,
                      size: 24,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'roboto',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xffd9d9d9),
          ),
        ),
      ],
    );
  }
}
