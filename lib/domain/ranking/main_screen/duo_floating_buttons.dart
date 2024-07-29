import 'package:flutter/material.dart';
import 'package:movemore/general/exercise/exercise.dart';
import 'package:movemore/general/theme/text_style_theme.dart';

class DuoFloatingButtons extends StatelessWidget {
  final Exercise? exercise;
  final void Function() onMoveTapped;
  final void Function() onFriendsTapped;
  final int friendRequestCount;
  const DuoFloatingButtons({
    super.key,
    this.exercise,
    required this.onMoveTapped,
    required this.onFriendsTapped,
    required this.friendRequestCount,
  });

  get friendRequestCountLabel {
    if (friendRequestCount <= 9) {
      return friendRequestCount.toString();
    }
    return '9+';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(width: 8),
        if (exercise != null)
          ClipPath(
            clipper: InwardClipper(),
            child: SizedBox(
              height: 64,
              width: 260,
              child: FloatingActionButton(
                key: GlobalKey(),
                heroTag: 'perform-exercise-hero',
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    bottomLeft: Radius.circular(12),
                    topRight: Radius.circular(0),
                    bottomRight: Radius.circular(0),
                  ),
                ),
                onPressed: onMoveTapped,
                child: RichText(
                  text: TextSpan(children: [
                    TextSpan(
                      text: "Move",
                      style: MMTextStyleTheme.standardLargeBold,
                    ),
                    TextSpan(
                      text: exercise!.pluralizedName,
                      style: MMTextStyleTheme.standardLarge,
                    ),
                  ]),
                ),
              ),
            ),
          ),
        Transform.translate(
          offset: const Offset(-16, 0),
          child: Stack(
            children: [
              SizedBox(
                height: 64,
                width: 64,
                child: FloatingActionButton(
                  key: GlobalKey(),
                  heroTag: 'add-friend-hero',
                  onPressed: onFriendsTapped,
                  child: const Icon(Icons.person_add, size: 32),
                ),
              ),
              if (friendRequestCount > 0)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Color.fromARGB(255, 238, 102, 92),
                      shape: BoxShape.circle,
                    ),
                    width: 20,
                    alignment: Alignment.center,
                    transform: Matrix4.translationValues(7, -7, 0),
                    child: Text(
                      friendRequestCountLabel,
                      style: MMTextStyleTheme.standardExtraSmall,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class InwardClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.moveTo(245.248, 0);
    path.cubicTo(240.329, 2.72946, 237, 7.97595, 237, 14);
    path.lineTo(237, 50);
    path.cubicTo(237, 56.0241, 240.329, 61.2705, 245.248, 64);
    path.lineTo(8, 64);
    path.cubicTo(3.58172, 64, 0, 60.4183, 0, 56);
    path.lineTo(0, 8);
    path.cubicTo(0, 3.58172, 3.58172, 0, 8, 0);
    path.lineTo(245.248, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
