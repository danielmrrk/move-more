import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:movemore/domain/auth/auth_service.dart';
import 'package:movemore/domain/onboarding/welcome_screen.dart';
import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/theme/text_style_theme.dart';
import 'package:movemore/general/util/navigation.dart';
import 'package:movemore/general/util/snackbar.dart';

class SettingsScreen extends StatelessWidget {
  SettingsScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  final roundedButtonStyle = ButtonStyle(
    shape: MaterialStateProperty.all(
      RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Settings",
          style: MMTextStyleTheme.standardLarge,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                  style: roundedButtonStyle,
                  onPressed: () async {
                    if (await AuthService().logout()) {
                      if (context.mounted) {
                        navigateTo(
                          const WelcomeScreen(),
                          context,
                          removeHistory: true,
                        );
                      }
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 16.0),
                    child: Text("Log out"),
                  )),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: () {
                _onBuildDialog(context);
              },
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.background,
                  border: Border.all(color: MMColorTheme.blue500, width: 2),
                  boxShadow: [
                    BoxShadow(color: MMColorTheme.neutral1000.withOpacity(.12), blurRadius: 3, offset: const Offset(0, 1)),
                    BoxShadow(color: MMColorTheme.neutral1000.withOpacity(.24), blurRadius: 2, offset: const Offset(0, 1))
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Delete Account",
                    textAlign: TextAlign.center,
                    style: MMTextStyleTheme.standardSmallGrey,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void _onBuildDialog(BuildContext context) {
    Get.defaultDialog(
        title: "Do you really want to delete your account?",
        titleStyle: MMTextStyleTheme.standardSmall,
        titlePadding: const EdgeInsets.all(24),
        backgroundColor: MMColorTheme.blue500,
        content: Column(
          children: [
            RichText(
                text: TextSpan(
              children: [
                TextSpan(text: "Then enter ", style: MMTextStyleTheme.standardSmall),
                TextSpan(text: "DELETE", style: MMTextStyleTheme.standardSmallSemiBold),
              ],
            )),
            const SizedBox(height: 8),
            Form(
              key: _formKey,
              child: TextFormField(
                textAlign: TextAlign.center,
                validator: _validateDeleteText,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: roundedButtonStyle,
                onPressed: () {
                  _safelyDeleteAccount(context);
                },
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text("Confirm")),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "This will delete all your data from our systems.This cannot be undone.",
              style: MMTextStyleTheme.standardExtraSmallGrey,
            )
          ],
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24));
  }

  String? _validateDeleteText(String? value) {
    if (value != "DELETE") {
      return "Please enter DELETE";
    }
    return null;
  }

  void _safelyDeleteAccount(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    } else {
      if (await AuthService().delete()) {
        if (context.mounted) {
          navigateTo(const WelcomeScreen(), context, removeHistory: true);
          showVisualFeedbackSnackbar(context, "Account deleted successfully");
        }
      } else {
        if (context.mounted) {
          showVisualFeedbackSnackbar(context, "Couldn't delete your account. Try again later.");
        }
      }
    }
  }
}
