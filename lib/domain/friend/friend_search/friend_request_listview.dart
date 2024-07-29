import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemore/domain/friend/friend.dart';
import 'package:movemore/domain/friend/friend_search/friend_custom_dismissible.dart';
import 'package:movemore/domain/friend/friend_service.dart';
import 'package:movemore/domain/friend/friend_search/friend_list_item.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/general/theme/color_theme.dart';
import 'package:movemore/general/util/snackbar.dart';

class FriendRequestListView extends ConsumerStatefulWidget {
  const FriendRequestListView({
    super.key,
    required this.friendRequests,
    required this.fetchFriendRequest,
  });

  final List<Friend> friendRequests;
  final Function() fetchFriendRequest;

  @override
  ConsumerState<FriendRequestListView> createState() => _FriendRequestListViewState();
}

class _FriendRequestListViewState extends ConsumerState<FriendRequestListView> {
  int? dismissIndex;

  @override
  Widget build(BuildContext context) {
    return SliverAnimatedList(
      key: GlobalKey(),
      initialItemCount: widget.friendRequests.length,
      itemBuilder: (context, index, animation) {
        final friend = widget.friendRequests[index];
        return FriendCustomDismissible(
          key: ValueKey(index),
          deletionColor: Theme.of(context).colorScheme.error.withOpacity(0.75),
          acceptColor: MMColorTheme.iconColor.withOpacity(0.75),
          acceptFunction: () => _onAcceptFriendRequestSwiped(friend),
          dismissFunction: () => _onRejectFriendRequest(friend, index, context),
          child: _createFriendListItem(friend, animation, index, context),
        );
      },
    );
  }

  Widget _createFriendListItem(Friend friend, Animation animation, int index, BuildContext context) {
    return SizeTransition(
      sizeFactor: animation.drive(Tween(begin: 0, end: 1)),
      child: FriendListItem(
        username: friend.username,
        action: IconButton(
          onPressed: () => _onAcceptFriendRequestButtonClicked(context, friend, index),
          icon: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  void _onAcceptFriendRequestButtonClicked(BuildContext context, Friend friend, int index) {
    SliverAnimatedList.of(context).removeItem(
      index,
      (context, animation) => SizeTransition(
        sizeFactor: animation.drive(
          Tween(begin: 0, end: 1),
        ),
        child: _createFriendListItem(friend, animation, index, context),
      ),
    );
    _acceptFriend(friend);
  }

  void _onAcceptFriendRequestSwiped(Friend friend) {
    _acceptFriend(friend);
  }

  void _acceptFriend(Friend friend) async {
    widget.friendRequests.remove(friend);
    try {
      await friendService.acceptFriendRequest(friend.userId);
      if (context.mounted) {
        showVisualFeedbackSnackbar(
          context,
          "You are now friends with ${friend.username}",
        );
      }
    } on ApiException catch (e) {
      if (context.mounted) {
        showApiException(e, context);
      }
    }
  }

  void _onRejectFriendRequest(Friend friend, int index, BuildContext context) async {
    widget.friendRequests.remove(friend);
    SliverAnimatedList.of(context).removeItem(index, (context, animation) => const SizedBox());
    bool hasUndone = false;
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context)
        .showSnackBar(
          SnackBar(
            duration: const Duration(seconds: 3),
            content: Text("Friend ${friend.username} rejected"),
            action: SnackBarAction(
              label: "Undo",
              onPressed: () {
                hasUndone = true;
                _undoRejectRejectFriendRequest(context, index, friend);
              },
            ),
          ),
        )
        .closed
        .then(
      (value) async {
        if (!hasUndone) {
          _rejectFriendRequest(friend, context);
        }
      },
    );
  }

  void _undoRejectRejectFriendRequest(BuildContext context, int index, Friend friend) {
    SliverAnimatedList.of(context).insertItem(index);
    widget.friendRequests.insert(index, friend);
  }

  void _rejectFriendRequest(Friend friend, BuildContext context) async {
    try {
      await friendService.rejectFriendRequest(friend.userId);
    } on ApiException catch (e) {
      if (context.mounted) {
        showApiException(e, context);
      }
    }
  }
}
