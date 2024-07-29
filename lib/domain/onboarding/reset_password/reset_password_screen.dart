import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:movemore/domain/auth/auth_service.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/domain/onboarding/reset_password/account_recovery_service.dart';
import 'dart:async';

import 'package:movemore/domain/onboarding/reset_password/recovery_code_field/recovery_code_form_field.dart';
import 'package:movemore/domain/ranking/main_screen.dart';
import 'package:movemore/general/util/navigation.dart';
import 'package:movemore/general/util/snackbar.dart';

class ResetPasswordScreen extends ConsumerStatefulWidget {
  const ResetPasswordScreen({
    super.key,
    required this.resetEmail,
  });

  final String resetEmail;

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();

  String _newPassword = '';
  String _enteredRecoveryCode = '';
  bool _showPassword = false;

  @override
  Widget build(BuildContext context) {
    double bottomSpace = 0;
    double adjustedButtonSpace = 156;
    final double keyboardSpace = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardSpace == 0) {
      bottomSpace = 120;
    } else {
      if (keyboardSpace >= 120) {
        bottomSpace = 0;
        adjustedButtonSpace = 30;
      } else {
        bottomSpace = 120 - keyboardSpace;
        adjustedButtonSpace -= 10;
      }
    }
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
      ),
      body: WillPopScope(
        onWillPop: () async {
          bool isKeyboardVisible = FocusScope.of(context).isFirstFocus;
          if (isKeyboardVisible) {
            FocusScope.of(context).unfocus();
            await Future.delayed(const Duration(milliseconds: 300));
          }
          return true;
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, bottomSpace),
          child: Column(
            children: [
              Text(
                "Reset password",
                textAlign: TextAlign.center,
                style: GoogleFonts.lora(fontSize: 32, fontWeight: FontWeight.w600),
              ),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "We sent an email to",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        widget.resetEmail,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(
                        height: 28,
                      ),
                      RecoveryCodeFormField(
                        autofocus: true,
                        onSaved: (recoveryCode) => _enteredRecoveryCode = recoveryCode ?? '',
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      TextFormField(
                        scrollPadding: const EdgeInsets.only(bottom: 96),
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
                          _newPassword = value!;
                        },
                      ),
                      SizedBox(height: adjustedButtonSpace),
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: FilledButton(
                          onPressed: () {
                            _resetPassword();
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                              RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          child: const Text('Reset Password'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _togglePasswordVisibility() {
    setState(() {
      _showPassword = !_showPassword;
    });
  }

  String? _validatePassword(value) {
    if (value == null || value.toString().length < 8 || value.isEmpty) {
      return "password must be at least 8 characters long";
    }
    return null;
  }

  void _resetPassword() {
    if (_formKey.currentState == null) {
      return;
    }
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      _passwordRequest(_newPassword);
    }
  }

  void _passwordRequest(String password) async {
    try {
      await accountRecoveryService.resetPassword(widget.resetEmail, _enteredRecoveryCode, _newPassword);
      await authService.login({
        "usernameOrEmail": widget.resetEmail,
        "password": _newPassword,
      });
      if (!context.mounted) {
        return;
      }
      navigateTo(const MainScreen(), context);
    } on ApiException catch (e) {
      if (!context.mounted) {
        return;
      }
      showApiException(e, context);
    }
  }

  void _onRecoveryCodeSaved(String value) {
    _enteredRecoveryCode = value;
  }
}
