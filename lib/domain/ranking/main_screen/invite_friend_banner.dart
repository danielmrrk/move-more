import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:movemore/domain/onboarding/invitation_service.dart';
import 'package:movemore/general/theme/controls_theme.dart';
import 'package:movemore/general/theme/text_style_theme.dart';

import '../../../general/theme/color_theme.dart';

class InviteFriendBanner extends ConsumerStatefulWidget {
  const InviteFriendBanner({
    super.key,
    required this.onDismissed,
  });

  final void Function() onDismissed;

  @override
  ConsumerState<InviteFriendBanner> createState() => _InviteFriendBannerState();
}

class _InviteFriendBannerState extends ConsumerState<InviteFriendBanner> with TickerProviderStateMixin {
  late final AnimationController _dismissAnimationController;
  late final Animation<double> _dismissAnimation;
  // ignore: avoid_init_to_null
  double? _maxHeight = null;
  final GlobalKey _childKey = GlobalKey();
  bool _isCreatingInvitationLink = false;

  @override
  void initState() {
    super.initState();
    _dismissAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    CurvedAnimation curvedDismissAnimation = CurvedAnimation(parent: _dismissAnimationController, curve: Curves.fastEaseInToSlowEaseOut);
    _dismissAnimation = Tween(begin: 1.0, end: 0.01).animate(curvedDismissAnimation)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          widget.onDismissed();
        }
      });

    WidgetsBinding.instance.addPostFrameCallback(_afterLayout);
  }

  _afterLayout(_) {
    final RenderObject renderBox = _childKey.currentContext!.findRenderObject()!;

    setState(() {
      _maxHeight = renderBox.paintBounds.size.height;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _childKey,
      clipBehavior: Clip.hardEdge,
      height: _maxHeight == null ? null : _maxHeight! * _dismissAnimation.value,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.background,
        border: Border.all(color: MMColorTheme.blue500, width: 2),
        boxShadow: [
          BoxShadow(color: MMColorTheme.neutral1000.withOpacity(.12), blurRadius: 3, offset: const Offset(0, 1)),
          BoxShadow(color: MMColorTheme.neutral1000.withOpacity(.24), blurRadius: 2, offset: const Offset(0, 1))
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Stack(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(
                    height: 12,
                    width: 12,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      onPressed: _onDismiss,
                      icon: const Icon(Icons.close),
                      iconSize: 12.0,
                      color: MMColorTheme.neutral400,
                      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero)),
                    ),
                  ),
                ],
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      'MoveMore is more fun\nwith more Friends.',
                      style: MMTextStyleTheme.standardLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Invite your friends.',
                      style: MMTextStyleTheme.standardSmallGrey,
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 44,
                height: 44,
                child: FilledButton(
                  onPressed: _onOpenInviteDialog,
                  style: MMButtonTheme.roundedButtonStyle,
                  child: _isCreatingInvitationLink
                      ? const CircularProgressIndicator.adaptive()
                      : Icon(Platform.isIOS ? Icons.ios_share : Icons.share),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _onOpenInviteDialog() async {
    if (_isCreatingInvitationLink) {
      return;
    }
    setState(() {
      _isCreatingInvitationLink = true;
    });
    await invitationService.openInvitationShareDialog();
    setState(() {
      _isCreatingInvitationLink = false;
    });
  }

  _onDismiss() {
    _dismissAnimationController.forward();
  }
}
