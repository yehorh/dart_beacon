import 'dart:async';

import 'package:test/test.dart';
import 'package:state_beacon_core/state_beacon_core.dart';

import '../../common.dart';

void main() {
  test('should convert a beacon to a stream', () async {
    var beacon = Beacon.writable(0);
    var onCanceledCalled = false;
    var stream = beacon.toStream(
      onCancel: () {
        onCanceledCalled = true;
      },
    );

    expect(stream, isA<Stream<int>>());

    expect(
        stream,
        emitsInOrder([
          0,
          1,
          2,
          emitsDone,
        ]));

    beacon.value = 1;
    beacon.value = 2;
    beacon.dispose();

    expect(onCanceledCalled, true);
  });

  test('next method completes with the setted value', () async {
    var beacon = Beacon.writable(0);

    Timer(k10ms, () => beacon.set(42));

    final result = await beacon.next();

    expect(result, 42);
  });

  test('next method with filter only completes with matching values', () async {
    var beacon = Beacon.writable(0);

    final futureValue = beacon.next(filter: (value) => value.isEven);

    Timer(
      k10ms,
      () => beacon
        ..set(3) // Not even, should be ignored
        ..set(42), // Even, should be completed with this value
    );

    final result = await futureValue;

    expect(result, 42);
  });

  test('next method with timeout completes with peek value on timeout',
      () async {
    var beacon = Beacon.writable(0);

    final futureValue = beacon.next(timeout: k10ms);

    // Delay beyond timeout
    await Future<void>.delayed(k10ms * 2);

    final result = await futureValue;

    expect(result, beacon.peek());
  });

  test('next method unsubscribes after value is setted', () async {
    var beacon = Beacon.writable(0);

    final futureValue = beacon.next();

    expect(beacon.listenersCount, 1);

    beacon.set(42);

    await futureValue; // Ensure the future is completed

    expect(beacon.listenersCount, 0);

    // set more values, and the future should not complete again
    beacon.set(99);

    // Assert that the future didn't complete again
    expect(futureValue, completes);

    // should be the same value as before
    await expectLater(await futureValue, 42);
  });

  test('should return a BufferedCountBeacon', () {
    var beacon = Beacon.writable(0);

    var buffered = beacon.buffer(3);

    expect(buffered, isA<BufferedCountBeacon<int>>());

    beacon
      ..set(1)
      ..set(2)
      ..set(3);

    expect(buffered.value, [0, 1, 2]);
  });

  test('should work properly when wrapping a lazy beacon', () async {
    var beacon = Beacon.lazyWritable<int>();

    var buffered = beacon.buffer(3);
    var bufferedTime = beacon.bufferTime(duration: k10ms);
    var debounced = beacon.debounce(duration: k10ms, startNow: false);
    var throttled = beacon.throttle(duration: k10ms, startNow: false);
    var filtered = beacon.filter(
      startNow: false,
      filter: (p0, p1) => p1.isEven,
    );

    beacon
      ..set(1)
      ..set(2)
      ..set(3)
      ..set(5);

    expect(buffered.value, [1, 2, 3]);

    expect(debounced.value, 1);

    expect(throttled.value, 1);

    expect(filtered.value, 2);

    expect(bufferedTime.value, <int>[]);

    await Future<void>.delayed(k10ms * 2);

    expect(debounced.value, 5);

    expect(throttled.value, 1);

    expect(bufferedTime.value, <int>[1, 2, 3, 5]);
  });

  test('should return a BufferedTimeBeacon', () async {
    var beacon = Beacon.writable(0);

    var buffered = beacon.bufferTime(duration: k10ms);

    expect(buffered, isA<BufferedTimeBeacon<int>>());

    buffered
      ..add(1)
      ..add(2)
      ..add(3);

    expect(buffered.currentBuffer.value, [0, 1, 2, 3]);
    expect(buffered.value, isEmpty);

    await Future<void>.delayed(k10ms * 2);
    expect(buffered.value, [0, 1, 2, 3]);
    expect(buffered.currentBuffer.value, isEmpty);
  });

  test('should return a DebouncedBeacon', () async {
    var beacon = Beacon.writable(0);

    var debounced = beacon.debounce(duration: k10ms);

    expect(debounced, isA<DebouncedBeacon<int>>());

    beacon
      ..set(1)
      ..set(2)
      ..set(3);

    expect(debounced.value, 0);

    await Future<void>.delayed(k10ms * 2);

    expect(debounced.value, 3);
  });

  test('should return a ThrottledBeacon', () async {
    var beacon = Beacon.writable(0);

    var throttled = beacon.throttle(duration: k10ms);

    expect(throttled, isA<ThrottledBeacon<int>>());

    beacon
      ..set(1)
      ..set(2)
      ..set(3);

    expect(throttled.value, 0);

    await Future<void>.delayed(k10ms * 2);

    expect(throttled.value, 0);
  });

  test('should return a FilteredBeacon', () async {
    var beacon = Beacon.writable(0);

    var filtered = beacon.filter(filter: (prev, next) => next.isEven);

    expect(filtered, isA<FilteredBeacon<int>>());

    beacon
      ..set(1)
      ..set(2)
      ..set(3);

    expect(filtered.value, 2);
  });

  test('should throw when wrapping a lazy beacon with start=true', () {
    var beacon = Beacon.lazyWritable<int>();

    expect(
      () => beacon.throttle(duration: k10ms),
      throwsException,
    );

    expect(
      () => beacon.debounce(duration: k10ms),
      throwsException,
    );

    expect(
      () => beacon.filter(),
      throwsException,
    );
  });
}