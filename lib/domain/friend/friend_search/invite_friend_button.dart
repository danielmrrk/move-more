import 'package:flutter/material.dart';
import 'package:movemore/domain/onboarding/invitation_service.dart';
import 'package:movemore/general/theme/text_style_theme.dart';

class InviteFriendButton extends StatelessWidget {
  const InviteFriendButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FilledButton(
        style: ButtonStyle(
          padding: const MaterialStatePropertyAll(EdgeInsets.all(12)),
          shape: MaterialStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
        ),
        onPressed: () => invitationService.openInvitationShareDialog(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Invite Friend', style: MMTextStyleTheme.standardSmall),
            const SizedBox(
              width: 10,
            ),
            const Icon(Icons.share),
          ],
        ),
      ),
    );
  }
}
