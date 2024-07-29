import 'package:custom_sliding_segmented_control/custom_sliding_segmented_control.dart';
import 'package:flutter/material.dart';
import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/theme/controls_theme.dart';

enum FriendPage {
  searchFriend,
  friendList,
}

class FriendToggleBar extends StatefulWidget {
  const FriendToggleBar({
    super.key,
    required this.onSwitchScreen,
    this.initialPage = FriendPage.searchFriend,
  });

  final FriendPage initialPage;
  final void Function(FriendPage) onSwitchScreen;

  @override
  State<FriendToggleBar> createState() => _FriendToggleBarState();
}

class _FriendToggleBarState extends State<FriendToggleBar> {
  FriendPage? _currentScreen;
  @override
  void initState() {
    super.initState();
    _currentScreen = widget.initialPage;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CustomSlidingSegmentedControl<int>(
            initialValue: widget.initialPage == FriendPage.searchFriend ? 1 : 2,
            children: {
              1: Text(
                'Search',
                style: MMSegmentTheme(isActive: _currentScreen == FriendPage.searchFriend).slidingColor,
              ),
              2: Text(
                'Friends',
                style: MMSegmentTheme(isActive: _currentScreen == FriendPage.friendList).slidingColor,
              ),
            },
            onValueChanged: (value) {
              FriendPage nextScreen = value == 1 ? FriendPage.searchFriend : FriendPage.friendList;
              if (_currentScreen != nextScreen) {
                widget.onSwitchScreen(nextScreen);
                setState(() {
                  _currentScreen = nextScreen;
                });
              }
            },
            decoration: BoxDecoration(
              color: MMColorTheme.blue800,
              borderRadius: BorderRadius.circular(40),
            ),
            thumbDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.background,
              borderRadius: BorderRadius.circular(20),
            ),
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInToLinear,
            height: 42,
            fixedWidth: 120,
            innerPadding: const EdgeInsets.all(4),
          ),
        ],
      ),
    );
  }
}
