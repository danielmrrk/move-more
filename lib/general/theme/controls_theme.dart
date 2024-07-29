import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movemore/general/theme/color_theme.dart';

class MMButtonTheme {
  static final roundedButtonStyle = ButtonStyle(
    padding: MaterialStateProperty.all(const EdgeInsets.all(0)),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
  static final standardButtonStyle = ButtonStyle(
    padding: MaterialStateProperty.all(
      const EdgeInsets.symmetric(vertical: 16, horizontal: 48),
    ),
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );

  static final fullWidthButtonStyle = ButtonStyle(
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
  );
}

class MMSegmentTheme {
  MMSegmentTheme({required this.isActive});
  bool isActive;
  TextStyle get slidingColor => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: isActive ? MMColorTheme.segmentTextColor : Colors.white,
      );
}
