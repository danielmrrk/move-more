import 'package:flutter/material.dart';
import 'package:movemore/domain/network/api_exception.dart';

showApiException(ApiException exception, BuildContext context) {
  _showSnackbar(context, exception.message ?? 'an unknown error occurred. Please try again later.', 3);
}

void showVisualFeedbackSnackbar(BuildContext context, String text, {int seconds = 2}) {
  _showSnackbar(context, text, seconds);
}

void _showSnackbar(BuildContext context, String text, int seconds) {
  ScaffoldMessenger.of(context).clearSnackBars();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: Duration(seconds: seconds),
      content: Text(text),
    ),
  );
}
