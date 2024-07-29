import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:movemore/domain/auth/token_service.dart';
import 'package:movemore/domain/friend/friend.dart';

import 'package:movemore/domain/friend/friend_search/friend_search_result.dart';
import 'package:movemore/domain/friend/friend_service.dart';
import 'package:movemore/general/sliver/single_child_delegate.dart';
import 'package:movemore/general/theme/text_style_theme.dart';
import 'package:movemore/general/util/debouncer.dart';
import 'package:movemore/domain/friend/friend_search/friend_request_listview.dart';

import 'package:movemore/domain/friend/friend_search/invite_friend_button.dart';
import 'package:movemore/domain/friend/friend_search/custom_search_bar.dart';
import 'package:movemore/domain/friend/friend_search/friend_search_listview.dart';
import 'package:movemore/domain/friend/friend_search/username_display.dart';
import 'package:movemore/general/util/timeout.dart';
import 'package:movemore/general/widget/sliver_refresh_control.dart';

class SearchFriendPage extends ConsumerStatefulWidget {
  final String? initialQuery;
  const SearchFriendPage({super.key, this.initialQuery});

  @override
  ConsumerState<SearchFriendPage> createState() => _SearchFriendScreenState();
}

class _SearchFriendScreenState extends ConsumerState<SearchFriendPage> {
  _SearchFriendScreenState() {
    searchDebouncer = Debouncer<String>(const Duration(milliseconds: 500), _onQueryDebounced);
  }

  final _formKey = GlobalKey<FormState>();

  List<Friend> friendRequestList = [];
  late Debouncer<String> searchDebouncer;
  List<FriendSearchResult> _friendSearchResults = [];
  bool isTyping = false;
  String searchQuery = '';

  bool get shouldShowNothingFound => !isTyping && searchQuery.length >= 3 && _friendSearchResults.isEmpty;
  bool get shouldShowLoading => isTyping;
  bool get shouldShowQueryToShort => !isTyping && searchQuery.length < 3;
  bool get shouldShowSearchResults => !isTyping && searchQuery.length >= 3 && _friendSearchResults.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _updateQuery(widget.initialQuery ?? '');
  }

  @override
  Widget build(BuildContext context) {
    final username = tokenService.username ?? '';
    return CustomScrollView(
      scrollBehavior: const CupertinoScrollBehavior(),
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: SliverSingleChildDelegate(
            minHeight: 68,
            maxHeight: 68,
            child: Container(
              color: Theme.of(context).colorScheme.background,
              padding: const EdgeInsets.only(bottom: 20.0),
              child: CustomSearchBar(
                formKey: _formKey,
                initialValue: searchQuery,
                onQueryTyped: _updateQuery,
              ),
            ),
          ),
        ),
        if (searchQuery.isNotEmpty)
          _buildSearchFriendView()
        else ...[
          SliverRefreshControl(onRefresh: () => timeout(_fetchFriendRequests())),
          SliverToBoxAdapter(
            child: Container(
              color: Theme.of(context).colorScheme.background,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 52.0),
                    child: UsernameDisplay(
                      username: username,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: SliverSingleChildDelegate(
              minHeight: 70,
              maxHeight: 70,
              child: Container(
                color: Theme.of(context).colorScheme.background,
                padding: const EdgeInsets.only(bottom: 20),
                child: const InviteFriendButton(),
              ),
            ),
          ),
          SliverMainAxisGroup(
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 52)),
              const SliverToBoxAdapter(
                child: Text(
                  "FRIEND REQUESTS",
                  style: MMTextStyleTheme.headerStyle,
                  textAlign: TextAlign.start,
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 8),
              ),
              if (friendRequestList.isEmpty)
                SliverToBoxAdapter(
                  child: Text(
                    "There are no outstanding friend requests",
                    style: MMTextStyleTheme.standardSmallGrey,
                  ),
                )
              else ...[
                FriendRequestListView(
                  friendRequests: friendRequestList,
                  fetchFriendRequest: _fetchFriendRequests,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 120)),
              ]
            ],
          )
        ]
      ],
    );
  }

  Widget _buildSearchFriendView() {
    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(
          child: SizedBox(
            height: 30,
            child: Text(
              shouldShowQueryToShort ? 'Please enter at least 3 letters' : '',
              style: MMTextStyleTheme.standardSmall,
              textAlign: TextAlign.center,
            ),
          ),
        ),
        if (shouldShowLoading)
          SliverToBoxAdapter(
            child: Center(
              child: LoadingAnimationWidget.staggeredDotsWave(
                color: Colors.white,
                size: 50,
              ),
            ),
          ),
        if (shouldShowSearchResults)
          FriendSearchListView(
            searchResults: _friendSearchResults,
          )
        else if (shouldShowNothingFound)
          SliverToBoxAdapter(
            child: Column(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(text: 'No users found with name ', style: MMTextStyleTheme.standardSmall),
                      TextSpan(text: searchQuery, style: MMTextStyleTheme.standardSmallSemiBold),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const InviteFriendButton(),
              ],
            ),
          )
      ],
    );
  }

  Future<void> _fetchFriendRequests() async {
    List<Friend> friendRequests = await friendService.listFriendRequests();
    setState(() {
      friendRequestList = friendRequests;
    });
  }

  Future<List<FriendSearchResult>> _fetchFriendSearchResults(String value) async {
    List<FriendSearchResult> searchResults = await friendService.findFriends(value);
    List<FriendSearchResult> friendSearchResults = searchResults.where((result) => !result.areFriends).toList();
    return friendSearchResults;
  }

  void _updateQuery(String query) {
    setState(() {
      searchQuery = query;
      isTyping = true;
    });
    searchDebouncer.value = query;
  }

  Future<void> _onQueryDebounced(String query) async {
    List<FriendSearchResult> friendSearchResults = [];
    if (query.length >= 3) {
      friendSearchResults = await _fetchFriendSearchResults(query);
    }
    if (query.isEmpty) {
      _fetchFriendRequests();
    }
    setState(() {
      isTyping = false;
      _friendSearchResults = friendSearchResults;
    });
  }
}
