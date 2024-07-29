import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SliverRefreshControl extends StatelessWidget {
  final Future<dynamic> Function() onRefresh;

  const SliverRefreshControl({super.key, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return CupertinoSliverRefreshControl(
      builder: Theme.of(context).platform == TargetPlatform.iOS ? _buildAppleRefreshIndicator : _buildAndroidRefreshIndicator,
      onRefresh: () async {
        await Future.wait([
          onRefresh(),
          // wait at least 750ms before the loading spinner disapears. Otherwise the UI feels like it did not reload.
          Future.delayed(const Duration(milliseconds: 750)),
        ]);
      },
    );
  }

  Widget _buildAppleRefreshIndicator(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    const Curve opacityCurve = Interval(0.4, 0.8, curve: Curves.easeInOut);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: refreshState == RefreshIndicatorMode.drag
            ? Opacity(
                opacity: opacityCurve.transform(min(pulledExtent / refreshIndicatorExtent, 1.0)),
                child: CupertinoActivityIndicator.partiallyRevealed(
                  radius: 14.0,
                  progress: min(
                    pulledExtent / refreshTriggerPullDistance,
                    1.0,
                  ),
                ),
              )
            : Opacity(
                opacity: opacityCurve.transform(min(pulledExtent / refreshIndicatorExtent, 1.0)),
                child: const CupertinoActivityIndicator(radius: 14.0),
              ),
      ),
    );
  }

  Widget _buildAndroidRefreshIndicator(
    BuildContext context,
    RefreshIndicatorMode refreshState,
    double pulledExtent,
    double refreshTriggerPullDistance,
    double refreshIndicatorExtent,
  ) {
    const Curve opacityCurve = Interval(0.4, 0.8, curve: Curves.easeInOut);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: refreshState == RefreshIndicatorMode.drag
            ? Opacity(
                opacity: opacityCurve.transform(min(pulledExtent / refreshIndicatorExtent, 1.0)),
                child: CircularProgressIndicator(
                  value: min(
                    pulledExtent / refreshTriggerPullDistance,
                    1.0,
                  ),
                  strokeWidth: 2.0,
                ),
              )
            : Opacity(
                opacity: opacityCurve.transform(min(pulledExtent / refreshIndicatorExtent, 1.0)),
                child: const CircularProgressIndicator(strokeWidth: 2.0),
              ),
      ),
    );
  }
}
