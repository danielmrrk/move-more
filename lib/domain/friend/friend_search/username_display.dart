import 'package:flutter/material.dart';
import 'package:movemore/general/theme/text_style_theme.dart';

class UsernameDisplay extends StatelessWidget {
  const UsernameDisplay({super.key, required this.username});

  final String username;
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Your friends can find you\nwith your username:',
          style: MMTextStyleTheme.standardSmall,
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 12,
        ),
        Text(
          username,
          style: MMTextStyleTheme.standardSmallSemiBold,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
