import 'package:flutter/material.dart';

navigateTo(Widget page, BuildContext context, {bool removeHistory = false}) {
  final route = MaterialPageRoute(
    builder: (context) {
      return page;
    },
  );
  if (removeHistory) {
    return Navigator.pushAndRemoveUntil(context, route, ((route) => false));
  } else {
    return Navigator.push(context, route);
  }
}
