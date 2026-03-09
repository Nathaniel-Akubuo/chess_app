import 'package:chess_app/ui/widgets/images/image_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:stacked/stacked.dart';

import 'startup_viewmodel.dart';

class StartupView extends StackedView<StartupViewModel> {
  const StartupView({Key? key}) : super(key: key);

  @override
  Widget builder(BuildContext context, StartupViewModel viewModel, Widget? child) => const _View();

  @override
  StartupViewModel viewModelBuilder(BuildContext context) => StartupViewModel();

  @override
  void onViewModelReady(StartupViewModel viewModel) =>
      SchedulerBinding.instance.addPostFrameCallback((timeStamp) => viewModel.runStartupLogic());
}

class _View extends StatefulWidget {
  const _View();

  @override
  State<_View> createState() => _ViewState();
}

class _ViewState extends State<_View> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<Offset> _knightOffset;
  late final Animation<double> _knightOpacity;
  late final Animation<double> _logoOpacity;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _knightOffset = TweenSequence<Offset>([
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(-0.3, 0.3),
          end: const Offset(-0.3, -0.3),
        ),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: const Offset(-0.3, -0.3),
          end: const Offset(0.3, -0.3),
        ),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.7, curve: Curves.easeOut),
      ),
    );

    _knightOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.7, curve: Curves.easeIn),
    );

    _logoOpacity = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Stack(
            alignment: Alignment.center,
            children: [
              const SizedBox.expand(),
              SlideTransition(
                position: _knightOffset,
                child: Opacity(
                  opacity: _knightOpacity.value,
                  child: const _KnightIcon(),
                ),
              ),
              Opacity(
                opacity: _logoOpacity.value,
                child: const ImageCard.local('na8.svg', width: 140),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _KnightIcon extends StatelessWidget {
  const _KnightIcon();

  @override
  Widget build(BuildContext context) {
    return const ImageCard.local(
      'knight-white.svg',
      size: 72,
    );
  }
}
