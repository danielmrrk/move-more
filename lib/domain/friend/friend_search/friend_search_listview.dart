import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:movemore/domain/friend/friend_search/friend_search_result.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/domain/friend/friend_service.dart';
import 'package:movemore/general/theme/text_style_theme.dart';
import 'package:movemore/general/util/snackbar.dart';
import 'package:movemore/domain/friend/friend_search/friend_list_item.dart';
import 'package:movemore/domain/friend/friend_search/invite_friend_button.dart';

class FriendSearchListView extends ConsumerStatefulWidget {
  const FriendSearchListView({
    super.key,
    required this.searchResults,
  });

  final List<FriendSearchResult> searchResults;

  @override
  ConsumerState<FriendSearchListView> createState() => _FriendSearchListViewState();
}

class _FriendSearchListViewState extends ConsumerState<FriendSearchListView> {
  @override
  Widget build(BuildContext context) {
    final inviteFriendWidget = Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Text(
            'You can\'t find your friend here?',
            style: MMTextStyleTheme.standardSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 16,
          ),
          const InviteFriendButton()
        ],
      ),
    );

    return SliverAnimatedList(
      initialItemCount: widget.searchResults.length + 1,
      itemBuilder: ((context, index, animation) => index != widget.searchResults.length
          ? _createFriendListItem(widget.searchResults[index], animation, index, context)
          : inviteFriendWidget),
    );
  }

  Widget _createFriendListItem(FriendSearchResult friend, Animation animation, int index, BuildContext context) {
    return SizeTransition(
      sizeFactor: animation.drive(Tween(begin: 0, end: 1)),
      child: FriendListItem(
        username: friend.username,
        action: IconButton(
          onPressed: () => _onSendFriendRequest(context, friend, index),
          icon: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  void _onSendFriendRequest(BuildContext context, FriendSearchResult friend, int index) {
    SliverAnimatedList.of(context).removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation.drive(
          Tween(begin: 0, end: 1),
        ),
        child: _createFriendListItem(friend, animation, index, context),
      ),
    );
    widget.searchResults.remove(friend);
    _sendFriendRequest(friend, context);
  }

  void _sendFriendRequest(FriendSearchResult foundFriend, BuildContext context) async {
    try {
      await friendService.sendFriendRequest(foundFriend.userId);
      if (context.mounted) {
        showVisualFeedbackSnackbar(
          context,
          "Sent friend request to ${foundFriend.username}",
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        showApiException(e, context);
      }
    }
  }
}
