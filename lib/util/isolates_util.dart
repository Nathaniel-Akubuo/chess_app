import 'dart:isolate';

import 'package:flutter/services.dart';

class IsolatesUtil {
  static Future<T> computeIsolate<T>(Future Function() function) async {
    final receivePort = ReceivePort();
    var rootToken = RootIsolateToken.instance!;
    await Isolate.spawn<_IsolateData>(
      _isolateEntry,
      _IsolateData(
        token: rootToken,
        function: function,
        answerPort: receivePort.sendPort,
      ),
    );
    return await receivePort.first;
  }

  static void _isolateEntry(_IsolateData isolateData) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(isolateData.token);
    final answer = await isolateData.function();
    isolateData.answerPort.send(answer);
  }
}

class _IsolateData {
  final RootIsolateToken token;
  final Function function;
  final SendPort answerPort;

  _IsolateData({
    required this.token,
    required this.function,
    required this.answerPort,
  });
}
