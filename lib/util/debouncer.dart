import 'dart:async';

class Debouncer {
  final Duration _delay;
  Timer? _timer;

  Debouncer({required Duration delay}) : _delay = delay;

  void debounce(Function() action) {
    _timer?.cancel();
    _timer = Timer(_delay, action);
  }

  void cancel() => _timer?.cancel();
}
