import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemore/domain/friend/friend.dart';
import 'package:movemore/domain/friend/friend_search/friend_custom_dismissible.dart';
import 'package:movemore/domain/friend/friend_search/friend_list_item.dart';
import 'package:movemore/domain/friend/friend_service.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/general/theme/text_style_theme.dart';
import 'package:movemore/general/util/snackbar.dart';

class FriendListScreen extends ConsumerStatefulWidget {
  const FriendListScreen({super.key});

  @override
  ConsumerState<FriendListScreen> createState() => _FriendListScreenState();
}

class _FriendListScreenState extends ConsumerState<FriendListScreen> {
  List<Friend> _friendList = [];

  @override
  void initState() {
    super.initState();
    _fetchFriendList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('FRIENDS', style: MMTextStyleTheme.headerStyle),
        const SizedBox(
          height: 4,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 96.0),
            child: AnimatedList(
              key: GlobalKey(),
              initialItemCount: _friendList.length,
              itemBuilder: (context, index, animation) => SizeTransition(
                sizeFactor: animation.drive(Tween(begin: 0, end: 1)),
                child: FriendCustomDismissible(
                  dismissFunction: () => _onDeleteFriend(_friendList[index], index, context),
                  deletionColor: Theme.of(context).colorScheme.error.withOpacity(0.75),
                  child: FriendListItem(
                    username: _friendList[index].username,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _fetchFriendList() async {
    List<Friend> friendList = await friendService.listFriends();
    setState(() {
      _friendList = friendList;
    });
  }

  void _onDeleteFriend(Friend friend, int index, BuildContext context) async {
    final readdToken = await _deleteFriend(friend);
    if (readdToken == null || !context.mounted) {
      return;
    }
    _friendList.remove(friend);
    SliverAnimatedList.of(context).removeItem(index, (context, animation) => const SizedBox());
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 5),
        content: Text("Friend ${friend.username} deleted"),
        action: SnackBarAction(
          label: "Undo",
          onPressed: () => _onUndoDeleteFriend(context, index, friend, readdToken),
        ),
      ),
    );
  }

  void _onUndoDeleteFriend(BuildContext context, int index, Friend friend, String readdToken) async {
    if (context.mounted) {
      AnimatedList.of(context).insertItem(index);
    }
    _friendList.insert(index, friend);
    await friendService.redeemFriendAddToken(readdToken);
  }

  Future<String?> _deleteFriend(Friend friend) async {
    try {
      return await friendService.removeFriend(friend.userId);
    } on ApiException catch (e) {
      if (context.mounted) {
        showApiException(e, context);
      }
      return null;
    }
  }
}
