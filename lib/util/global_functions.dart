import 'dart:developer' as dev;

void logfn(Object? object, [String? methodName]) {
  if (methodName == null) {
    dev.log('logfn: $object', time: DateTime.now());
  } else {
    dev.log('logfn: $methodName: $object', time: DateTime.now());
  }
}
