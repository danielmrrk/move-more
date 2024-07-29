import 'package:flutter/material.dart';
import 'package:movemore/domain/network/network_controller.dart';
import 'package:movemore/general/theme/controls_theme.dart';
import 'package:movemore/general/theme/text_style_theme.dart';

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "No Connection",
              style: MMTextStyleTheme.titleLargeBold,
            ),
            const SizedBox(height: 24),
            Text(
              "No Internet connection found.\nPlease check your internet\nsettings.",
              style: MMTextStyleTheme.standardLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(
              height: 120,
            ),
            FilledButton(
              onPressed: () {
                NetworkController.hasNoConnection();
              },
              style: MMButtonTheme.fullWidthButtonStyle,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                child: Text('Try again'),
              ),
            )
          ],
        ),
      ),
    );
  }
}
