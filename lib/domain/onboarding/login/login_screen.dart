import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemore/domain/auth/auth_service.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/domain/ranking/main_screen.dart';

import 'package:movemore/domain/onboarding/reset_password/password_forgot_screen.dart';
import 'package:movemore/general/theme/controls_theme.dart';
import 'package:movemore/general/util/constants.dart';
import 'package:movemore/general/util/navigation.dart';
import 'package:movemore/general/util/snackbar.dart';

import 'package:movemore/domain/onboarding/onboarding_frame.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _enteredEmail;
  String? _enteredPassword;
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    return OnboardingFrame(
      title: 'Login',
      belowButton: TextButton(
        onPressed: () => navigateTo(PasswordForgotScreen(), context),
        child: const Text(
          'Forgot your password?',
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                label: Text("Email"),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: _validateEmail,
              onSaved: (value) {
                _enteredEmail = value!;
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
              onSaved: (value) {
                _enteredPassword = value!;
              },
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton(
                onPressed: () {
                  _login(ref);
                },
                style: MMButtonTheme.fullWidthButtonStyle,
                child: const Text('Login'),
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

  String? _validateEmail(String? value) {
    if (value == null || !emailPattern.hasMatch(value.toLowerCase())) {
      return "please enter a valid email";
    }
    return null;
  }

  String? _validatePassword(value) {
    if (value == null || value.toString().length < 8 || value.isEmpty) {
      return "password must be at least 8 characters long";
    }
    return null;
  }

  void _login(WidgetRef ref) async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        await authService.login({
          "usernameOrEmail": _enteredEmail,
          "password": _enteredPassword,
        });
        if (context.mounted) {
          navigateTo(
            const MainScreen(),
            context,
            removeHistory: true,
          );
        }
      } on ApiException catch (e) {
        if (context.mounted) {
          showApiException(e, context);
        }
      }
    }
  }
}
