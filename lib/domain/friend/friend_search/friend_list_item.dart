import 'package:flutter/material.dart';
import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/theme/text_style_theme.dart';

class FriendListItem extends StatelessWidget {
  const FriendListItem({
    super.key,
    required this.username,
    this.action,
  });

  final String username;
  final Widget? action;

  bool get hasAction => action != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      width: double.infinity,
      decoration: BoxDecoration(
        color: MMColorTheme.blue800,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Text(
            username,
            style: MMTextStyleTheme.standardLarge,
          ),
          const Spacer(),
          if (hasAction) action!
        ],
      ),
    );
  }
}
