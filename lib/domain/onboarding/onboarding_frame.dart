import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class OnboardingFrame extends StatelessWidget {
  const OnboardingFrame({super.key, required this.title, required this.child, this.belowButton});

  final Widget child;
  final Widget? belowButton;
  final String title;

  @override
  Widget build(BuildContext context) {
    double bottomSpace = 0;
    final double keyboardSpace = MediaQuery.of(context).viewInsets.bottom;

    // animate bottom space or find layout flow solution
    if (keyboardSpace == 0) {
      bottomSpace = 88;
    } else {
      if (keyboardSpace >= 88) {
        bottomSpace = 0;
      } else {
        bottomSpace = 88 - keyboardSpace;
      }
    }

    return Scaffold(
      appBar: AppBar(),
      body: Padding(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomSpace),
        child: Column(
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.w600),
            ),
            Expanded(
              child: child,
            ),
            SizedBox(height: 32, child: belowButton),
          ],
        ),
      ),
    );
  }
}
