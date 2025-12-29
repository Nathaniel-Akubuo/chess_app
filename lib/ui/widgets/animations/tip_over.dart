import 'dart:math' as math;
import 'package:chess_app/ui/common/app_values.dart';
import 'package:flutter/material.dart';

class TipOver extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final bool play;
  final double angle;
  final Curve curve;
  final Duration delay;

  const TipOver({
    super.key,
    required this.child,
    this.duration = fiveHundredMS,
    this.play = true,
    this.angle = 75,
    this.curve = Curves.bounceOut,
    this.delay = Duration.zero,
  });

  @override
  State<TipOver> createState() => _TipOverState();
}

class _TipOverState extends State<TipOver> with SingleTickerProviderStateMixin {
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
      CurvedAnimation(parent: _controller, curve: widget.curve),
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
  void didUpdateWidget(covariant TipOver oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.play) {
      _startWithDelay();
    } else {
      _controller.reset();
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
        final height = constraints.maxHeight;

        return AnimatedBuilder(
          animation: _controller,
          builder: (_, child) {
            return Transform(
              transform: Matrix4.identity()
                ..translate(0.0, height)
                ..rotateZ(_rotation.value)
                ..translate(0.0, -height),
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
