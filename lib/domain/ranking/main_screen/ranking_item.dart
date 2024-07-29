import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:movemore/domain/ranking/ranking_symbol.dart';
import 'package:movemore/general/theme/text_style_theme.dart';

import '../ranking.dart';
import '../../../general/theme/color_theme.dart';

class RankingItem extends ConsumerStatefulWidget {
  const RankingItem({super.key, required this.rank, required this.rankedUser, this.rankingChange = RankingSymbol.neutral});

  final int rank;
  final RankedUser rankedUser;
  final RankingSymbol rankingChange;

  @override
  ConsumerState<RankingItem> createState() => _RankingItemState();
}

class _RankingItemState extends ConsumerState<RankingItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Theme.of(context).colorScheme.background,
        border: Border.all(color: MMColorTheme.blue500, width: 2),
        boxShadow: [
          BoxShadow(color: MMColorTheme.neutral1000.withOpacity(.12), blurRadius: 3, offset: const Offset(0, 1)),
          BoxShadow(color: MMColorTheme.neutral1000.withOpacity(.24), blurRadius: 2, offset: const Offset(0, 1))
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Text(
              widget.rank.toString(),
              style: MMTextStyleTheme.standardLarge,
            ),
          ),
          SvgPicture.asset(
            "assets/${widget.rankingChange.rankSymbol}.svg",
            width: 12,
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 5,
            child: Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              width: 220,
              height: 44,
              child: Text(
                widget.rankedUser.username,
                style: MMTextStyleTheme.standardLarge,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            width: 72,
            height: 44,
            child: Text(
              widget.rankedUser.score.toString(),
              textAlign: TextAlign.end,
              style: MMTextStyleTheme.standardLarge.copyWith(color: MMColorTheme.neutral300),
            ),
          ),
        ],
      ),
    );
  }
}
