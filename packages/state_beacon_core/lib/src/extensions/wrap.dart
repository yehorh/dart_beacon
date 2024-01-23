part of '../base_beacon.dart';

extension WritableWrap<T, U> on BeaconConsumer<T, U> {
  /// Wraps a `ReadableBeacon` and comsume its values
  ///
  /// Supply a (`then`) function to customize how the emitted values are
  /// processed.
  ///
  /// NB: If no `then` function is provided, the value type of the target must be
  /// the same as the wrapper beacon.
  ///
  /// If the `disposeTogether` parameter is set to `true` (default: false), the wrapper beacon
  /// will be disposed when the target beacon is disposed and vice versa.
  ///
  /// Example:
  /// ```dart
  /// var bufferBeacon = Beacon.bufferedCount<String>(10);
  /// var count = Beacon.writable(5);
  ///
  /// // Wrap the bufferBeacon with the readableBeacon and provide a custom transformation.
  /// bufferBeacon.wrap(count, then: (value) {
  ///   // Custom transformation: Convert the value to a string and add it to the buffer.
  ///   bufferBeacon.add(value.toString());
  /// });
  ///
  /// print(bufferBeacon.buffer); // Outputs: ['5']
  ///
  /// count.value = 10;
  ///
  /// print(bufferBeacon.buffer); // Outputs: ['5', '10']
  /// ```
  void wrap<U>(
    ReadableBeacon<U> target, {
    void Function(U)? then,
    bool startNow = true,
    bool disposeTogether = false,
  }) {
    if (_wrapped.containsKey(target.hashCode)) return;

    if (then == null && T != U) {
      throw WrapTargetWrongTypeException(name, target.name);
    }

    if (startNow && target.isEmpty) {
      throw Exception(
        'target($target) is uninitialized so startNow must be false',
      );
    }

    final fn = then ?? ((val) => this._onNewValueFromWrapped(val as T));

    final unsub = target.subscribe((val) {
      fn(val);
    }, startNow: startNow);

    _wrapped[target.hashCode] = unsub;

    if (disposeTogether) {
      bool isDisposing = false;

      target.onDispose(() {
        if (isDisposing) return;
        isDisposing = true;
        dispose();
      });

      this.onDispose(() {
        if (isDisposing) return;
        isDisposing = true;
        target.dispose();
      });
    }

    return;
  }
}
