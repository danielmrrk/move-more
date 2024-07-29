import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:movemore/general/theme/color_theme.dart';

class MMTextStyleTheme {
  static final titleLargeBold = GoogleFonts.inter(
    fontSize: 32,
    color: MMColorTheme.neutral100,
    fontWeight: FontWeight.w600,
  );

  static final standardLargeBold = GoogleFonts.inter(
    fontSize: 20,
    color: MMColorTheme.neutral100,
    fontWeight: FontWeight.w900,
  );

  static final standardLarge = GoogleFonts.inter(
    fontSize: 20,
    color: MMColorTheme.neutral100,
    fontWeight: FontWeight.w400,
  );

  static final standardSmall = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: MMColorTheme.neutral100,
  );

  static final standardExtraSmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: MMColorTheme.neutral100,
  );

  static final standardExtraSmallGrey = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: MMColorTheme.neutral300,
  );

  static final standardExtraLarge = GoogleFonts.inter(
    fontSize: 24,
    color: MMColorTheme.neutral100,
    fontWeight: FontWeight.w400,
  );

  static final standardExtraLargeBold = GoogleFonts.inter(
    fontSize: 24,
    color: MMColorTheme.neutral100,
    fontWeight: FontWeight.w600,
  );

  static final standardSmallGrey = GoogleFonts.inter(
    fontSize: 16,
    color: MMColorTheme.neutral300,
    fontWeight: FontWeight.w400,
  );

  static final standardSmallSemiBold = GoogleFonts.inter(
    fontSize: 16,
    color: MMColorTheme.neutral100,
    fontWeight: FontWeight.w600,
  );

  static const headerStyle = TextStyle(
    fontFamily: "robot",
    fontWeight: FontWeight.w700,
    fontSize: 12,
  );
}
