import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/domain/onboarding/choose_first_exercise_screen.dart';
import 'package:movemore/domain/auth/auth_service.dart';

import 'package:movemore/general/theme/controls_theme.dart';
import 'package:movemore/general/theme/text_style_theme.dart';
import 'package:movemore/general/util/constants.dart';
import 'package:movemore/general/util/navigation.dart';
import 'package:movemore/general/util/snackbar.dart';
import 'package:movemore/domain/onboarding/onboarding_frame.dart';

class ChooseUsernameScreen extends ConsumerWidget {
  ChooseUsernameScreen({
    super.key,
    this.registerEmail,
    this.registerPassword,
    this.oauthInformation,
  }) : assert((registerEmail != null && registerPassword != null) || oauthInformation != null);

  final String? registerEmail;
  final String? registerPassword;
  final OAuthInformation? oauthInformation;

  final _formKey = GlobalKey<FormState>();
  String? _registerUsername;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingFrame(
      title: 'Choose your\nusername',
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextFormField(
              decoration: const InputDecoration(
                label: Text("Username"),
                prefixIcon: Icon(Icons.person),
                errorMaxLines: 2,
              ),
              validator: _validateUsername,
              onSaved: (username) {
                _registerUsername = username!.trim();
              },
            ),
            const SizedBox(
              height: 4,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Your Username will be visible to other users.",
                style: MMTextStyleTheme.standardExtraSmall,
              ),
            ),
            const SizedBox(height: 64),
            SizedBox(
              width: double.infinity,
              height: 60,
              child: FilledButton(
                onPressed: () {
                  _onRegister(context, ref);
                },
                style: MMButtonTheme.fullWidthButtonStyle,
                child: const Text('Sign Up'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String? _validateUsername(value) {
    if (value == null || value.trim().length < 3 || value.trim().length > 16) {
      return "enter a username between 3 to 16 characters.";
    } else if (!usernamePattern.hasMatch(value)) {
      value = value.toString().trim();
      final invalidCharMatches = usernameInvalidCharPattern.allMatches(value);
      final invalidCharacters = invalidCharMatches.map((match) => match.group(0)).join(',');
      return 'Username may not contain $invalidCharacters\n';
    }
    return null;
  }

  void _onRegister(BuildContext context, WidgetRef ref) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (oauthInformation != null) {
      _onRegisterWithOAuth(context, ref);
    } else {
      _onRegisterWithEmail(context, ref);
    }
  }

  void _onRegisterWithOAuth(BuildContext context, WidgetRef ref) async {
    try {
      await authService.registerWithOAuth(_registerUsername!, oauthInformation!);
    } on ApiException catch (e) {
      if (context.mounted) {
        showApiException(e, context);
      }
      return;
    }
    if (context.mounted) {
      navigateTo(
        const ChooseFirstExerciseScreen(),
        context,
        removeHistory: true,
      );
    }
  }

  void _onRegisterWithEmail(BuildContext context, WidgetRef ref) async {
    try {
      await authService.register({
        "email": registerEmail,
        "username": _registerUsername,
        "password": registerPassword,
      });
      await authService.login({
        "usernameOrEmail": registerEmail,
        "password": registerPassword,
      });
    } on ApiException catch (e) {
      if (context.mounted) {
        showApiException(e, context);
      }
      return;
    }
    if (context.mounted) {
      navigateTo(
        const ChooseFirstExerciseScreen(),
        context,
        removeHistory: true,
      );
    }
  }
}
