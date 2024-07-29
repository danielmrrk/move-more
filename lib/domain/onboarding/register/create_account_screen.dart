import 'package:flutter/material.dart';
import 'package:movemore/domain/auth/auth_service.dart';

import 'package:movemore/domain/onboarding/register/choose_username_screen.dart';
import 'package:movemore/general/theme/controls_theme.dart';
import 'package:movemore/general/util/constants.dart';
import 'package:movemore/general/util/navigation.dart';

import 'package:movemore/domain/onboarding/onboarding_frame.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _showPassword = false;
  String? _registerEmail;
  String? _registerPassword;
  bool _isCheckingEmailAvailability = false;
  bool _isEmailInUse = false;

  @override
  Widget build(BuildContext context) {
    return OnboardingFrame(
      title: 'Create account',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextFormField(
              scrollPadding: const EdgeInsets.only(bottom: 96),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                label: const Text("Email"),
                prefixIcon: const Icon(Icons.email),
                errorText: _isEmailInUse ? 'This email is already in use' : null,
              ),
              validator: _validateEmail,
              onSaved: (email) {
                _registerEmail = email!.trim();
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              decoration: InputDecoration(
                label: const Text("Password"),
                prefixIcon: const Icon(Icons.key),
                suffixIcon: IconButton(
                  onPressed: _togglePasswordVisibility,
                  icon: Icon(_showPassword ? Icons.visibility : Icons.visibility_off),
                ),
              ),
              obscureText: !_showPassword,
              validator: _validatePassword,
              onSaved: (password) {
                _registerPassword = password;
              },
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton(
                onPressed: onPressNext,
                style: MMButtonTheme.fullWidthButtonStyle,
                child: _isCheckingEmailAvailability ? const CircularProgressIndicator.adaptive() : const Text('Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  void onPressNext() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();
    if (!await _isEmailAvailable(_registerEmail!)) {
      return;
    }
    if (!context.mounted) {
      return;
    }
    navigateTo(
        ChooseUsernameScreen(
          registerEmail: _registerEmail!,
          registerPassword: _registerPassword!,
        ),
        context);
  }

  Future<bool> _isEmailAvailable(String email) async {
    setState(() {
      _isCheckingEmailAvailability = true;
    });
    final isEmailAvailable = await authService.isEmailAvailable(email);
    setState(() {
      _isCheckingEmailAvailability = false;
      _isEmailInUse = !isEmailAvailable;
    });
    return isEmailAvailable;
  }

  String? _validateEmail(String? value) {
    if (value == null || !emailPattern.hasMatch(value.toLowerCase())) {
      return "please enter a valid email";
    }
    return null;
  }

  String? _validatePassword(value) {
    if (value == null || value.toString().length < 8) {
      return "password must be at least 8 characters long";
    }
    return null;
  }
}
