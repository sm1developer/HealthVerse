import 'package:flutter/material.dart';
import 'dart:ui';

class FrostedBarBackground extends StatelessWidget {
  const FrostedBarBackground({super.key, this.opacity = 0.6, this.sigma = 18});

  final double opacity;
  final double sigma;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(color: scheme.surface.withValues(alpha: opacity)),
      ),
    );
  }
}

class FrostedWrap extends StatelessWidget {
  const FrostedWrap({
    super.key,
    required this.child,
    this.opacity = 0.6,
    this.sigma = 18,
  });

  final Widget child;
  final double opacity;
  final double sigma;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: ColoredBox(
          color: scheme.surface.withValues(alpha: opacity),
          child: child,
        ),
      ),
    );
  }
}
