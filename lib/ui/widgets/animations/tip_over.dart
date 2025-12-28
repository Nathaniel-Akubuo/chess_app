import 'dart:math' as math;
import 'package:chess_app/ui/common/app_values.dart';
import 'package:flutter/material.dart';

class TipOverPhysicsBounce extends StatefulWidget {
  final Widget child;
  final bool play;
  final double angle; // degrees, max rotation
  final Duration duration;
  final Duration delay; // new

  const TipOverPhysicsBounce({
    super.key,
    required this.child,
    this.play = true,
    this.angle = 75,
    this.duration = twoSeconds,
    this.delay = Duration.zero,
  });

  @override
  State<TipOverPhysicsBounce> createState() => _TipOverPhysicsBounceState();
}

class _TipOverPhysicsBounceState extends State<TipOverPhysicsBounce>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    _rotation = Tween<double>(
      begin: 0,
      end: widget.angle * math.pi / 180,
    ).animate(
      CurvedAnimation(parent: _controller, curve: _PhysicsBounceCurve()),
    );

    if (widget.play) {
      _startWithDelay();
    }
  }

  void _startWithDelay() async {
    if (widget.delay > Duration.zero) {
      await Future.delayed(widget.delay);
    }
    if (mounted) _controller.forward();
  }

  @override
  void didUpdateWidget(covariant TipOverPhysicsBounce oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play) {
      _startWithDelay();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final h = constraints.maxHeight;

        return AnimatedBuilder(
          animation: _rotation,
          builder: (_, child) {
            return Transform(
              transform: Matrix4.identity()
                ..translate(0.0, h)
                ..rotateZ(_rotation.value)
                ..translate(0.0, -h),
              alignment: Alignment.topCenter,
              child: child,
            );
          },
          child: widget.child,
        );
      },
    );
  }
}

/// Custom physics-style bounce curve (damped oscillation)
class _PhysicsBounceCurve extends Curve {
  @override
  double transform(double t) {
    const double bounces = 3; // number of bounces
    const double decay = 2.5; // damping factor
    return 1 - math.exp(-decay * t) * math.cos(bounces * math.pi * t);
  }
}
