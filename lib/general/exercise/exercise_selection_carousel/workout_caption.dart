import 'package:flutter/material.dart';
import 'package:movemore/general/theme/text_style_theme.dart';

class WorkoutCaption extends StatelessWidget {
  const WorkoutCaption({
    super.key,
    required this.title,
    this.sizeFactor = 0,
    this.topSafeSpaceExtend = 0,
    this.maxHeight,
  });

  final String title;
  final double sizeFactor;
  final double? maxHeight;
  final int androidMagicWidthPixel = 8;
  final double topSafeSpaceExtend;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      const padding = 8.0;
      final paddingBottom = 16.0 * sizeFactor;
      final topInset = topSafeSpaceExtend * MediaQuery.of(context).viewPadding.top;
      const minFontSize = 16;
      const maxFontSize = 20;
      final fontSize = minFontSize + (maxFontSize - minFontSize) * sizeFactor;
      final textStyle = MMTextStyleTheme.standardSmall.copyWith(fontSize: fontSize);
      final textSize = _calculateTextMinWidth(title, textStyle) * MediaQuery.of(context).textScaleFactor;

      final minTextWidth = textSize.width + 2 * padding + androidMagicWidthPixel;
      final maxWidth = constraints.maxWidth;
      final availableDynamicWidth = maxWidth - minTextWidth;
      final width = minTextWidth + availableDynamicWidth * sizeFactor;

      final minTextHeight = textSize.height + padding + 2;
      final availableDynamicHeight = maxHeight != null ? maxHeight! - minTextHeight : minTextHeight;
      final heigth = minTextHeight + availableDynamicHeight * sizeFactor + topInset;

      return Container(
        margin: EdgeInsetsDirectional.only(top: topInset),
        padding: EdgeInsets.fromLTRB(padding, padding, padding, paddingBottom),
        width: width,
        height: heigth,
        alignment: Alignment.bottomCenter,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.background,
          borderRadius: sizeFactor == 1
              ? null
              : const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
        ),
        child: DefaultTextStyle(
          style: textStyle,
          child: Text(
            title,
            textAlign: TextAlign.center,
          ),
        ),
      );
    });
  }

  Size _calculateTextMinWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    );
    textPainter.layout();
    return textPainter.size;
  }
}
