import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemore/domain/friend/friend_screen.dart';
import 'package:movemore/domain/friend/friend_service.dart';
import 'package:movemore/domain/network/api_exception.dart';
import 'package:movemore/domain/onboarding/invitation_service.dart';
import 'package:movemore/domain/push_notification/push_notification_service.dart';
import 'package:movemore/domain/ranking/main_screen/invite_friend_banner.dart';
import 'package:movemore/domain/ranking/ranking_symbol.dart';
import 'package:movemore/domain/setting/settings_screen.dart';
import 'package:movemore/domain/statistic/statistic_screen.dart';
import 'package:movemore/domain/training/instruction_screen.dart';
import 'package:movemore/domain/training/instruction_service.dart';
import 'package:movemore/domain/training/perform_exercise_screen.dart';
import 'package:movemore/general/exercise/exercise.dart';
import 'package:movemore/domain/ranking/ranking.dart';
import 'package:movemore/general/timeframe/timeframe.dart';
import 'package:movemore/general/exercise/exercise_service.dart';
import 'package:movemore/domain/ranking/ranking_service.dart';
import 'package:movemore/general/sliver/single_child_delegate.dart';
import 'package:movemore/general/util/navigation.dart';
import 'package:movemore/general/util/snackbar.dart';
import 'package:movemore/domain/ranking/main_screen/item_add_friend.dart';
import 'package:movemore/general/timeframe/timeframe_selection_bar.dart';

import 'package:movemore/general/exercise/exercise_selection_carousel/animateable_exercise_selection_carousel.dart';
import 'package:movemore/domain/ranking/main_screen/duo_floating_buttons.dart';
import 'package:movemore/domain/ranking/main_screen/ranking_item.dart';
import 'package:movemore/general/util/timeout.dart';
import 'package:movemore/general/widget/sliver_refresh_control.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({
    super.key,
    this.selectedExerciseId,
  });

  final int? selectedExerciseId;

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final TextStyle headerStyle = const TextStyle(
    fontFamily: "robot",
    fontWeight: FontWeight.w700,
    fontSize: 12,
  );

  RankingTimeframe _timeframe = RankingTimeframe.days1;
  Exercise? _selectedExercise;
  List<RankedUser> _rankedUsers = [];
  List<Exercise> _exercises = [];
  int _exerciseIndex = 0;

  bool _showInviteFriendBanner = false;

  int friendRequestCount = 0;

  List<int> _beforeLastChange = [];

  StreamSubscription<Uri>? _appLinkListener;
  StreamSubscription<RemoteMessage>? _firebaseMessageingListener;

  Exercise? get selectedExercise {
    if (_exerciseIndex >= _exercises.length) {
      return null;
    }
    return _exercises[_exerciseIndex];
  }

  @override
  void initState() {
    super.initState();
    _handleInvitationLinks();
    _registerDeepLinkListener();
    _fetchExercises();
    _fetchFriendRequestCount();
    pushNotificationService.setupPushNotifications();
    _registerExercisePushNotificationListener();
  }

  @override
  void dispose() {
    super.dispose();
    _appLinkListener?.cancel();
    _firebaseMessageingListener?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        CustomScrollView(
          scrollBehavior: const CupertinoScrollBehavior(),
          slivers: [
            SliverAppBar(
              actions: [
                Container(
                  margin: const EdgeInsets.only(right: 12),
                  child: TextButton(
                    onPressed: () {
                      navigateTo(SettingsScreen(), context);
                    },
                    child: const Text("Settings"),
                  ),
                )
              ],
              toolbarHeight: 32,
              automaticallyImplyLeading: false,
              forceMaterialTransparency: true,
            ),
            SliverLayoutBuilder(
              builder: (context, constraints) {
                const dotIndicatorHeight = 10.4;
                const dotIndicatorDistanceAbove = 12.0;
                const dotIndicatorDistanceBelow = 12.0;
                final expandedHeight =
                    constraints.crossAxisExtent * 1 / (16 / 9) + dotIndicatorDistanceAbove + dotIndicatorHeight + dotIndicatorDistanceBelow;
                final collapsedHeight = 58.0 + MediaQuery.of(context).viewPadding.top;
                return SliverPersistentHeader(
                  floating: true,
                  pinned: true,
                  delegate: SliverSingleChildDelegate(
                    minHeight: collapsedHeight,
                    maxHeight: expandedHeight,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.background,
                      ),
                      child: AnimateableExerciseSelectionCarousel(
                        exerciseIndex: _exerciseIndex,
                        exercises: _exercises,
                        onExerciseSelected: _onExerciseChanged,
                        expandedHeight: expandedHeight,
                        dotIndicatorDistanceAbove: dotIndicatorDistanceAbove,
                        dotIndicatorDistanceBelow: dotIndicatorDistanceBelow,
                        dotIndicatorHeight: dotIndicatorHeight,
                        collapsedHeight: collapsedHeight,
                      ),
                    ),
                  ),
                );
              },
            ),
            SliverRefreshControl(onRefresh: () => timeout(_fetchRankedUserList())),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(
                    height: 36,
                  ),
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 24.0),
                      child: Text(
                        "SCOREBOARD",
                        style: headerStyle,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                ],
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: SliverSingleChildDelegate(
                minHeight: 60,
                maxHeight: 60,
                child: Container(
                  color: Theme.of(context).colorScheme.background,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.only(bottom: 16),
                  child: TimeframeSelectionBar<RankingTimeframe>(
                    timeframes: RankingTimeframe.values,
                    onTimeFrameSelected: _onTimeframeChanged,
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24),
                    child: Row(
                      children: [
                        Text(
                          'RANK',
                          style: headerStyle,
                        ),
                        const Spacer(),
                        Text('NAME', style: headerStyle),
                        Expanded(
                          flex: 5,
                          child: Text(
                            _selectedExercise == null ? '' : _selectedExercise!.pluralizedName.toUpperCase(),
                            style: headerStyle,
                            textAlign: TextAlign.end,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                ],
              ),
            ),
            if (_showInviteFriendBanner)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12, top: 0),
                  child: InviteFriendBanner(
                    onDismissed: _onDismissInviteFriendBanner,
                  ),
                ),
              ),
            SliverList.builder(
                itemCount: _rankedUsers.length,
                itemBuilder: (context, index) {
                  int lastIndex = _beforeLastChange.isNotEmpty ? _beforeLastChange.indexOf(_rankedUsers[index].userId) : index;
                  return Padding(
                    padding: const EdgeInsets.only(left: 24, right: 24, bottom: 12, top: 0),
                    child: InkWell(
                      onTap: () => navigateTo(
                          StatisticScreen(
                            exerciseId: _selectedExercise!.id,
                            friend: _rankedUsers[index],
                          ),
                          context),
                      child: RankingItem(
                        rank: index + 1,
                        rankedUser: _rankedUsers[index],
                        rankingChange: RankingSymbol.fromChange(lastIndex, index),
                      ),
                    ),
                  );
                }),
            const SliverToBoxAdapter(
              child: ItemAddFriend(),
            ),
            const SliverToBoxAdapter(
              child: SizedBox(
                height: 96,
              ),
            )
          ],
        ),
        Column(
          children: [
            const Spacer(
              flex: 1,
            ),
            DuoFloatingButtons(
              exercise: _selectedExercise,
              onMoveTapped: _onNavigatePerformExercise,
              onFriendsTapped: _onNavigateFriendScreen,
              friendRequestCount: friendRequestCount,
            ),
            const SizedBox(
              height: 24,
            ),
          ],
        )
      ]),
    );
  }

  void _registerDeepLinkListener() {
    _appLinkListener = AppLinks().allUriLinkStream.listen((event) async {
      if (event.pathSegments.length == 2) {
        final invitationToken = event.pathSegments[1];
        final tokenValid = await friendService.redeemFriendAddToken(invitationToken);
        final username = event.pathSegments[0];
        if (!context.mounted) {
          return;
        }
        if (tokenValid) {
          showVisualFeedbackSnackbar(context, 'You are now friends with $username');
        } else {
          _onNavigateFriendScreen(initialQuery: username);
        }
      } else if (event.pathSegments.length == 1) {
        final username = event.pathSegments[0];
        _onNavigateFriendScreen(initialQuery: username);
      }
    });
  }

  void _registerExercisePushNotificationListener() {
    _firebaseMessageingListener = FirebaseMessaging.onMessage.listen(_handlePushMessage);
    FirebaseMessaging.onBackgroundMessage(_handlePushMessage);
  }

  Future<void> _handlePushMessage(RemoteMessage message) async {
    if (!message.data.containsKey('exerciseId')) {
      return;
    }
    final exerciseId = int.tryParse(message.data['exerciseId']);
    final displayedExercise = selectedExercise;
    if (exerciseId == null || displayedExercise == null) {
      return;
    }
    if (exerciseId == displayedExercise.id) {
      _fetchRankedUserList();
    }
  }

  Future<void> _handleInvitationLinks() async {
    final shouldShowFriendSearchScreen = await invitationService.onAppStartedAndLoggedIn();
    if (shouldShowFriendSearchScreen) {
      final username = await invitationService.getReferrerUsername();
      _onNavigateFriendScreen(initialQuery: username);
    } else {
      _fetchRankedUserList();
    }
  }

  Future<void> _fetchRankedUserList() async {
    if (_selectedExercise == null) {
      return;
    }
    try {
      final rankedUsers = await rankingService.getRankedUserList(_selectedExercise!.id, _timeframe);
      final beforeLastChange = await rankingService.getRankOrderBeforeLastChange(_selectedExercise!.id, _timeframe);
      setState(() {
        _rankedUsers = rankedUsers;
        _beforeLastChange = beforeLastChange;
        _maybeShowFriendInvitationBanner();
      });
    } on ApiException catch (e) {
      if (context.mounted) {
        showApiException(e, context);
      }
    }
  }

  void _fetchExercises() async {
    try {
      List<Exercise> exercises = await exerciseService.listExercises();

      setState(() {
        _exercises = exercises;
        if (exercises.isEmpty) {
          return;
        }

        if (widget.selectedExerciseId != null) {
          int selectedExerciseIndex = _exercises.indexWhere((exercise) => exercise.id == widget.selectedExerciseId);
          if (selectedExerciseIndex >= 0) {
            _exerciseIndex = selectedExerciseIndex;
          }
        }
        _selectedExercise = _exercises[_exerciseIndex];
        _fetchRankedUserList();
      });
    } on ApiException catch (e) {
      if (context.mounted) {
        showApiException(e, context);
      }
    }
  }

  void _fetchFriendRequestCount() async {
    final friendRequests = await friendService.listFriendRequests();
    setState(() {
      friendRequestCount = friendRequests.length;
    });
  }

  void _onExerciseChanged(Exercise exercise) {
    _selectedExercise = exercise;
    _exerciseIndex = _exercises.indexOf(exercise);
    _fetchRankedUserList();
  }

  void _onTimeframeChanged(covariant RankingTimeframe timeframe) {
    _timeframe = timeframe;
    _fetchRankedUserList();
  }

  void _maybeShowFriendInvitationBanner() async {
    bool shouldShowBanner = false;
    if (_rankedUsers.length < 5) {
      shouldShowBanner = !(await invitationService.wasBannerDismissedWithin4Days());
    }
    setState(() {
      _showInviteFriendBanner = shouldShowBanner;
    });
  }

  void _onDismissInviteFriendBanner() {
    setState(() {
      _showInviteFriendBanner = false;
    });
    invitationService.storeBannerDismissed();
  }

  void _onNavigatePerformExercise() async {
    if (_selectedExercise == null) {
      return;
    }
    final showInstructionScreen = await instructionScreenService.loadStateFromStorage();
    if (!context.mounted) {
      return;
    }
    navigateTo(
        showInstructionScreen
            ? InstructionScreen(
                selectedExercise: _selectedExercise!,
              )
            : PerformExerciseScreen(
                selectedExercise: _selectedExercise!,
              ),
        context);
  }

  void _onNavigateFriendScreen({String? initialQuery}) async {
    await navigateTo(
        FriendScreen(
          initialSearchQuery: initialQuery,
        ),
        context);
    _fetchRankedUserList();
    _fetchFriendRequestCount();
  }
}
