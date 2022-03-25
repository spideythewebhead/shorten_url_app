Future<void> nextTick() {
  return Future.microtask(() {});
}
