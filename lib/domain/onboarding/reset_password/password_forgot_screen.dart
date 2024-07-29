import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/domain/onboarding/reset_password/reset_password_screen.dart';
import 'package:movemore/domain/onboarding/reset_password/account_recovery_service.dart';
import 'package:movemore/general/theme/controls_theme.dart';
import 'package:movemore/general/util/constants.dart';
import 'package:movemore/general/util/navigation.dart';

import 'package:movemore/domain/onboarding/onboarding_frame.dart';
import 'package:movemore/general/util/snackbar.dart';

class PasswordForgotScreen extends StatelessWidget {
  PasswordForgotScreen({super.key});

  final _formKey = GlobalKey<FormState>();
  String _enteredEmail = '';

  @override
  Widget build(BuildContext context) {
    return OnboardingFrame(
      title: 'Reset password',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(
              flex: 2,
            ),
            Column(
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    label: Text("Email"),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: _validateEmail,
                  onSaved: (value) {
                    _enteredEmail = value!;
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  "Enter your email you used for sign up\nand we will send you a recovery code.",
                  style: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const Spacer(
              flex: 1,
            ),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton(
                onPressed: () async {
                  if (await _sendCode(context) && context.mounted) {
                    navigateTo(ResetPasswordScreen(resetEmail: _enteredEmail), context);
                  }
                },
                style: MMButtonTheme.fullWidthButtonStyle,
                child: const Text('Send Code'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    if (value == null || !emailPattern.hasMatch(value.toLowerCase())) {
      return "please enter a valid email";
    }
    return null;
  }

  Future<bool> _sendCode(BuildContext context) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      return await _sendRecoveryCodeSuccessful(_enteredEmail, context);
    }
    return false;
  }

  Future<bool> _sendRecoveryCodeSuccessful(String email, BuildContext context) async {
    try {
      await accountRecoveryService.requestRecoveryCode(email);
      if (!context.mounted) {
        return false;
      }
      showVisualFeedbackSnackbar(context, 'Recovery Code was sent to $email. Please check your spam folder as well.', seconds: 5);
      return true;
    } on ApiException catch (e) {
      showApiException(e, context);
    }
    return false;
  }
}
