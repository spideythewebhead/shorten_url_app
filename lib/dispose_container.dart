import 'dart:async';

import 'package:flutter/foundation.dart';

class DisposableContainer {
  final _disposables = <VoidCallback>[];

  void addSubscription(StreamSubscription subscription) {
    _disposables.add(subscription.cancel);
  }

  void addCallback(VoidCallback callback) {
    _disposables.add(callback);
  }

  DisposableContainer operator +(dynamic item) {
    if (item is StreamSubscription) {
      addSubscription(item);
    } else if (item is VoidCallback) {
      addCallback(item);
    }

    return this;
  }

  void dispose() {
    for (final disposable in _disposables) {
      disposable();
    }
  }
}
