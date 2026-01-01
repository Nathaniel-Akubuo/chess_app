import 'package:chess_app/ui/common/app_colors.dart';
import 'package:flutter/material.dart';

class BouncingDotsLoader extends StatefulWidget {
  const BouncingDotsLoader({super.key});

  @override
  State<BouncingDotsLoader> createState() => _BouncingDotsLoaderState();
}

class _BouncingDotsLoaderState extends State<BouncingDotsLoader>
    with SingleTickerProviderStateMixin {
  static const int _dotCount = 4;
  static const double _dotSize = 10;
  static const double _bounceHeight = 14;

  static const Duration _bounceDuration = Duration(seconds: 1);
  static const Duration _originalPeakDelay = Duration(milliseconds: 250);

  late final AnimationController _controller;
  late final double _peakDelayMs;

  final List<Color> _colors = const [
    k0D47A1,
    k2E7D32,
    k4FC3F7,
    kFBC02D,
  ];

  @override
  void initState() {
    super.initState();

    // Scale stagger to fit in 1 second total loop
    final originalTotalMs =
        _bounceDuration.inMilliseconds + (_dotCount - 1) * _originalPeakDelay.inMilliseconds;
    _peakDelayMs = _originalPeakDelay.inMilliseconds * (1000 / originalTotalMs);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  double _dotOffset(int index, double controllerValue) {
    final totalMs = _controller.duration!.inMilliseconds;
    final startMs = index * _peakDelayMs;
    final bounceMs = _bounceDuration.inMilliseconds;

    final currentMs = (controllerValue * totalMs - startMs + totalMs) % totalMs;

    if (currentMs > bounceMs) return 0;

    final t = currentMs / bounceMs;

    if (t <= 0.25) {
      return -_bounceHeight * Curves.easeOut.transform(t / 0.25);
    } else {
      return -_bounceHeight + _bounceHeight * Curves.elasticOut.transform((t - 0.25) / 0.75);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: _dotSize + _bounceHeight + 6,
      child: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_dotCount, (i) {
                return Transform.translate(
                  offset: Offset(0, _dotOffset(i, _controller.value)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Container(
                      width: _dotSize,
                      height: _dotSize,
                      decoration: BoxDecoration(
                        color: _colors[i],
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}
