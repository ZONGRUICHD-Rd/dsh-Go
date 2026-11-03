import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// iOS's own Liquid Glass (`UIGlassEffect`, ios/Runner/LiquidGlass.swift)
/// behind [child], in place of the Flutter blur of `GlassSurface`.
///
/// The native view fills the space [child] takes and only draws: touches go
/// to [child]. Its shape is a capsule ([capsule], also a circle when square)
/// or a continuous-corner rectangle of [borderRadius]; corners of radius 0
/// stay square (a sheet's bottom), the others share the largest radius.
class LiquidGlass extends StatelessWidget {
  const LiquidGlass({
    super.key,
    required this.dark,
    this.capsule = false,
    this.borderRadius = BorderRadius.zero,
    required this.child,
  });

  /// The native glass is there: the app runs on iOS.
  static bool get supported => Platform.isIOS;

  static const viewType = 'dsh/liquid_glass';

  /// The app's theme is dark (it can differ from the system's).
  final bool dark;
  final bool capsule;
  final BorderRadius borderRadius;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      // [child] lays out exactly as it would without the glass.
      fit: StackFit.passthrough,
      children: [
        Positioned.fill(
          child: IgnorePointer(
            child: ExcludeSemantics(
              child: UiKitView(
                // Creation parameters are read once: a change makes a new view.
                key: ValueKey((capsule, borderRadius, dark)),
                viewType: viewType,
                creationParams: {
                  'shape': capsule ? 'capsule' : 'rect',
                  'corners': [
                    borderRadius.topLeft.x,
                    borderRadius.topRight.x,
                    borderRadius.bottomLeft.x,
                    borderRadius.bottomRight.x,
                  ],
                  'dark': dark,
                },
                creationParamsCodec: const StandardMessageCodec(),
              ),
            ),
          ),
        ),
        child,
      ],
    );
  }
}
