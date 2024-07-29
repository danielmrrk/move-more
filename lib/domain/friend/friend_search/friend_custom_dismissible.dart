import 'package:flutter/material.dart';

class FriendCustomDismissible extends StatelessWidget {
  const FriendCustomDismissible({
    super.key,
    required this.deletionColor,
    this.acceptColor,
    this.acceptFunction,
    required this.dismissFunction,
    required this.child,
  }) : assert(
          (acceptFunction != null) == (acceptColor != null),
          "When initializing the acceptFunction parameter, the acceptColor parameter must also be initialized, and vice versa.",
        );

  final Color deletionColor;
  final Color? acceptColor;
  final Widget child;
  final Function()? acceptFunction;
  final Function() dismissFunction;

  bool get canSwipeToAccept => acceptColor != null && acceptFunction != null;

  @override
  Widget build(BuildContext context) {
    final Widget dismissContainer = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: deletionColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Padding(
        padding: EdgeInsets.only(right: 12.0),
        child: Align(
          alignment: Alignment.centerRight,
          child: Icon(Icons.delete),
        ),
      ),
    );

    final Widget acceptContainer = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: acceptColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Padding(
        padding: EdgeInsets.only(left: 12.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(Icons.check),
        ),
      ),
    );

    return Dismissible(
      key: UniqueKey(),
      secondaryBackground: !canSwipeToAccept ? null : dismissContainer,
      background: canSwipeToAccept ? acceptContainer : dismissContainer,
      direction: !canSwipeToAccept ? DismissDirection.endToStart : DismissDirection.horizontal,
      onDismissed: (direction) {
        if (direction == DismissDirection.endToStart) {
          dismissFunction();
        } else if (direction == DismissDirection.startToEnd && canSwipeToAccept) {
          acceptFunction!();
        }
      },
      child: child,
    );
  }
}
