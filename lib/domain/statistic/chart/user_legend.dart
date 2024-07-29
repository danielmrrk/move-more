import 'package:flutter/material.dart';
import 'package:movemore/domain/statistic/chart/chart_time_beam.dart';
import 'package:movemore/general/model/user.dart';
import 'package:movemore/general/theme/text_style_theme.dart';

class UserLegend extends StatelessWidget {
  final List<User> users;
  final ChartTimeBeam timebeam;
  const UserLegend({super.key, required this.users, required this.timebeam});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: users
          .map(
            (user) => Container(
              padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: timebeam.getUserColor(user.userId),
              ),
              child: Text(
                user.username,
                style: MMTextStyleTheme.standardSmall,
              ),
            ),
          )
          .toList(),
    );
  }
}
