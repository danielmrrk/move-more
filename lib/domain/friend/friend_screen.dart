import 'package:flutter/material.dart';
import 'package:movemore/domain/friend/friend_list/friend_list_screen.dart';
import 'package:movemore/domain/friend/friend_search/search_friend_page.dart';
import 'package:movemore/domain/friend/friend_toggle_bar.dart';

class FriendScreen extends StatefulWidget {
  final String? initialSearchQuery;
  final FriendPage initialPage;
  const FriendScreen({super.key, this.initialSearchQuery, this.initialPage = FriendPage.searchFriend});

  @override
  State<FriendScreen> createState() => _FriendScreenState();
}

class _FriendScreenState extends State<FriendScreen> {
  late Widget _currentScreen;
  String _title = 'Add Friends';

  @override
  void initState() {
    super.initState();
    if (widget.initialPage == FriendPage.searchFriend) {
      _currentScreen = SearchFriendPage(
        initialQuery: widget.initialSearchQuery,
      );
    } else {
      _onSwitchPage(widget.initialPage);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardIsOpened = MediaQuery.of(context).viewInsets.bottom > 100;
    return Scaffold(
      appBar: AppBar(
        title: Text(_title),
        forceMaterialTransparency: true,
        backgroundColor: Theme.of(context).colorScheme.background,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 24.0, 24.0, 0),
        child: Stack(
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _currentScreen,
            ),
            if (!keyboardIsOpened)
              Column(
                children: [
                  const Spacer(),
                  Container(
                    color: Theme.of(context).colorScheme.background,
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: FriendToggleBar(
                      onSwitchScreen: _onSwitchPage,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  void _onSwitchPage(FriendPage nextPage) {
    setState(() {
      if (nextPage == FriendPage.friendList) {
        _currentScreen = const FriendListScreen();
        _title = 'Friends';
      } else {
        _currentScreen = const SearchFriendPage();
        _title = 'Add Friends';
      }
    });
  }
}
