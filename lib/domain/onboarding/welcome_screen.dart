import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemore/domain/auth/auth_exception.dart';
import 'package:movemore/domain/auth/auth_service.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/domain/onboarding/register/choose_username_screen.dart';

import 'package:movemore/domain/onboarding/register/create_account_screen.dart';
import 'package:movemore/domain/onboarding/login/login_screen.dart';
import 'package:movemore/domain/ranking/main_screen.dart';

import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/util/navigation.dart';
import 'package:movemore/domain/onboarding/onboarding_frame.dart';
import 'package:movemore/general/util/snackbar.dart';

class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return OnboardingFrame(
      title: 'Welcome to\nMoveMore',
      belowButton: TextButton(
        onPressed: () => navigateTo(const LoginScreen(), context),
        child: const Text(
          'Already have an account?',
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: () => _loginWithGoogle(ref, context),
              icon: const Image(
                image: AssetImage('assets/google_logo.png'),
                height: 28,
              ),
              label: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Text('Continue with Google'),
              ),
              style: ButtonStyle(
                side: MaterialStateProperty.all(
                  BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                ),
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 24,
          ),
          if (Platform.isIOS)
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () => _loginWithApple(ref, context),
                icon: Icon(
                  Icons.apple,
                  color: Theme.of(context).colorScheme.onBackground,
                  size: 40,
                ),
                label: const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text('Continue with Apple'),
                ),
                style: ButtonStyle(
                  side: MaterialStateProperty.all(
                    BorderSide(color: Theme.of(context).colorScheme.primary, width: 2),
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          const SizedBox(
            height: 64,
          ),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 100,
                child: Divider(
                  color: MMColorTheme.neutral400,
                ),
              ),
              Padding(
                padding: EdgeInsets.all(12),
                child: Text("or"),
              ),
              SizedBox(
                width: 100,
                child: Divider(
                  color: MMColorTheme.neutral400,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 64,
          ),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: FilledButton(
              onPressed: () => navigateTo(const CreateAccountScreen(), context),
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              child: const Text("Create account"),
            ),
          )
        ],
      ),
    );
  }

  void _loginWithGoogle(WidgetRef ref, BuildContext context) async {
    final googleToken = await authService.authorizeGoogleAccess();
    _loginWithOAuth(context, authService, googleToken);
  }

  void _loginWithApple(WidgetRef ref, BuildContext context) async {
    final appleToken = await authService.authorizeAppleAccess();
    _loginWithOAuth(context, authService, appleToken);
  }

  void _loginWithOAuth(BuildContext context, AuthService authService, OAuthInformation? oAuthInformation) async {
    if (oAuthInformation == null) {
      showVisualFeedbackSnackbar(context, 'Login failed');
      return;
    }

    try {
      await authService.loginInWithOAuth(oAuthInformation);
      if (context.mounted) {
        navigateTo(
          const MainScreen(),
          context,
        );
      }
    } on UserNotRegisteredException catch (_) {
      if (context.mounted) {
        navigateTo(
          ChooseUsernameScreen(oauthInformation: oAuthInformation),
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
