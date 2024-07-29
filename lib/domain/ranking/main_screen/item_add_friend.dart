import 'package:flutter/material.dart';
import 'package:movemore/domain/friend/friend_screen.dart';
import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/theme/text_style_theme.dart';
import 'package:movemore/general/util/navigation.dart';

class ItemAddFriend extends StatelessWidget {
  const ItemAddFriend({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12, top: 0),
      child: InkWell(
        onTap: () {
          navigateTo(const FriendScreen(), context);
        },
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.background,
            border: Border.all(color: MMColorTheme.blue500, width: 2),
            boxShadow: [
              BoxShadow(color: MMColorTheme.neutral1000.withOpacity(.12), blurRadius: 3, offset: const Offset(0, 1)),
              BoxShadow(color: MMColorTheme.neutral1000.withOpacity(.24), blurRadius: 2, offset: const Offset(0, 1))
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(
              Icons.add,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text('Add Friends', style: MMTextStyleTheme.standardLarge),
          ]),
        ),
      ),
    );
  }
}
