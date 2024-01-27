// ignore_for_file: lines_longer_than_80_chars

part of 'creator.dart';

/// The class with all the methods for creating beacons.
class _BeaconCreator {
  const _BeaconCreator();

  /// Creates a `WritableBeacon` that can be read and written to.
  ///
  /// Example:
  /// ```dart
  /// var myBeacon = Beacon.writable(10);
  /// print(myBeacon.value); // Outputs: 10
  /// myBeacon.value = 20;
  /// ```
  WritableBeacon<T> writable<T>(
    T initialValue, {
    String? name,
  }) =>
      WritableBeacon<T>(
        initialValue: initialValue,
        name: name ?? 'Writable<$T>',
      );

  /// Like `Beacon.writable` but behaves like a late variable.
  /// It must be set before it's read.
  ///
  /// Throws [UninitializeLazyReadException] if it's read before being set.
  WritableBeacon<T> lazyWritable<T>({
    T? initialValue,
    String? name,
  }) =>
      WritableBeacon<T>(
        initialValue: initialValue,
        name: name ?? 'LazyWritable<$T>',
      );

  /// Creates an immutable `ReadableBeacon` from a value.
  /// This is useful for exposing a beacon's value to consumers
  /// without allowing them to modify it.
  ///
  /// ```dart
  /// final counter = Beacon.readable(10);
  /// counter.value = 10; // Compilation error
  ///
  ///
  /// final _internalCounter = Beacon.writable(10);
  ///
  /// // Expose the beacon's value without allowing it to be modified
  /// ReadableBeacon<int> get counter => _internalCounter;
  /// ```
  ReadableBeacon<T> readable<T>(
    T initialValue, {
    String? name,
  }) =>
      ReadableBeacon<T>(
        initialValue: initialValue,
        name: name ?? 'Readable<$T>',
      );

  /// Returns a `ReadableBeacon` and a function for setting its value.
  /// This is useful for creating a beacon that's readable by the public,
  /// but writable only by the owner.
  ///
  /// Example:
  /// ```dart
  /// var (count,setCount) = Beacon.scopedWritable(15);
  /// ```
  (ReadableBeacon<T>, void Function(T)) scopedWritable<T>(
    T initialValue, {
    String? name,
  }) {
    final beacon = WritableBeacon<T>(
      initialValue: initialValue,
      name: name ?? 'ScopedWritable<$T>',
    );
    return (beacon, beacon.set);
  }

  /// Creates a `DebouncedBeacon` that will delay updates to its value based on
  /// the duration. This is useful when you want to wait until a user has
  /// stopped typing before performing an action.
  ///
  /// ```dart
  /// var query = Beacon.debounced('', duration: Duration(seconds: 1));
  ///
  /// query.subscribe((value) {
  ///   print(value); // Outputs: 'apple' after 1 second
  /// });
  ///
  /// // simulate user typing
  /// query.value = 'a';
  /// query.value = 'ap';
  /// query.value = 'app';
  /// query.value = 'appl';
  /// query.value = 'apple';
  ///
  /// // after 1 second, the value will be updated to 'apple'
  /// ```
  DebouncedBeacon<T> debounced<T>(
    T initialValue, {
    required Duration duration,
    String? name,
  }) =>
      DebouncedBeacon<T>(
        initialValue: initialValue,
        duration: duration,
        name: name ?? 'DebouncedBeacon<$T>',
      );

  /// Like `Beacon.debounced` but behaves like a late variable.
  /// It must be set before it's read.
  ///
  /// Throws [UninitializeLazyReadException] if it's read before being set..
  DebouncedBeacon<T> lazyDebounced<T>({
    required Duration duration,
    T? initialValue,
    String? name,
  }) =>
      DebouncedBeacon<T>(
        initialValue: initialValue,
        duration: duration,
        name: name ?? 'LazyDebouncedBeacon<$T>',
      );

  /// Creates a `ThrottledBeacon` that will limit the rate of updates to
  /// its value based on the duration.
  ///
  /// If `dropBlocked` is `true`(default), values will be dropped while the
  /// beacon is blocked, otherwise, values will be buffered and emitted
  /// one by one when the beacon is unblocked.
  ///
  /// Example:
  /// ```dart
  /// const k10ms = Duration(milliseconds: 10);
  /// var beacon = Beacon.throttled(10, duration: k10ms);
  ///
  /// beacon.set(20);
  /// expect(beacon.value, equals(20)); // first update allowed
  ///
  /// beacon.set(30);
  /// expect(beacon.value, equals(20)); // too fast, update ignored
  ///
  /// await Future.delayed(k10ms * 1.1);
  ///
  /// beacon.set(30);
  /// expect(beacon.value, equals(30)); // throttle time passed, update allowed
  /// ```

  ThrottledBeacon<T> throttled<T>(
    T initialValue, {
    required Duration duration,
    bool dropBlocked = true,
    String? name,
  }) =>
      ThrottledBeacon<T>(
        initialValue: initialValue,
        duration: duration,
        dropBlocked: dropBlocked,
        name: name ?? 'ThrottledBeacon<$T>',
      );

  /// Like `Beacon.throttled` but behaves like a late variable. It must be set before it's read.
  ///
  /// Throws [UninitializeLazyReadException] if it's read before being set.
  ThrottledBeacon<T> lazyThrottled<T>({
    required Duration duration,
    T? initialValue,
    bool dropBlocked = true,
    String? name,
  }) =>
      ThrottledBeacon<T>(
        initialValue: initialValue,
        duration: duration,
        dropBlocked: dropBlocked,
        name: name ?? 'LazyThrottledBeacon<$T>',
      );

  /// Creates a `FilteredBeacon` that will only updates its value if it passes the filter criteria.
  /// The filter function receives the previous and new values as arguments.
  /// The filter function can also be changed using the `setFilter` method.
  ///
  /// ### Simple Example:
  /// ```dart
  /// var pageNum = Beacon.filtered(10, (prev, next) => next > 0); // only positive values are allowed
  /// pageNum.value = 20; // update is allowed
  /// pageNum.value = -5; // update is ignored
  /// ```

  /// ### Example when filter function depends on another beacon:
  /// ```dart
  /// var pageNum = Beacon.filtered(1); // we will set the filter function later
  ///
  /// final posts = Beacon.derivedFuture(() async {Repository.getPosts(pageNum.value);});
  ///
  /// pageNum.setFilter((prev, next) => posts.value is! AsyncLoading); // can't change pageNum while loading
  /// ```
  FilteredBeacon<T> filtered<T>(
    T initialValue, {
    BeaconFilter<T>? filter,
    String? name,
  }) {
    return FilteredBeacon<T>(
      initialValue: initialValue,
      filter: filter,
      name: name ?? 'FilteredBeacon<$T>',
    );
  }

  /// Like `Beacon.filtered` but behaves like a late variable. It must be set before it's read.
  /// The first will not be filtered if the `initialValue` is null.
  ///
  /// Throws [UninitializeLazyReadException] if it's read before being set.
  FilteredBeacon<T> lazyFiltered<T>({
    T? initialValue,
    BeaconFilter<T>? filter,
    String? name,
  }) {
    return FilteredBeacon<T>(
      initialValue: initialValue,
      filter: filter,
      name: name ?? 'LazyFilteredBeacon<$T>',
    );
  }

  /// Creates a `BufferedCountBeacon` that collects and buffers a specified number
  /// of values. Once the count threshold is reached, the beacon's value is updated
  /// with the list of collected values and the buffer is reset.
  ///
  /// This beacon is useful in scenarios where you need to aggregate a certain
  /// number of values before processing them together.
  ///
  /// Example:
  /// ```dart
  /// var countBeacon = Beacon.bufferedCount(3);
  /// countBeacon.subscribe((values) {
  ///   print(values); // Outputs the list of collected values
  /// });
  /// countBeacon.value = 1;
  /// countBeacon.value = 2;
  /// countBeacon.value = 3; // Triggers update with [1, 2, 3]
  /// ```
  BufferedCountBeacon<T> bufferedCount<T>(int count, {String? name}) =>
      BufferedCountBeacon<T>(
        countThreshold: count,
        name: name ?? 'BufferedCountBeacon<$T>',
      );

  /// Creates a `BufferedTimeBeacon` that collects values over a specified time duration.
  /// Once the time duration elapses, the beacon's value is updated with the list of
  /// collected values and the buffer is reset for the next interval.
  ///
  /// This beacon is ideal for scenarios where values need to be batched and processed
  /// periodically over time.
  ///
  /// Example:
  /// ```dart
  /// var timeBeacon = Beacon.bufferedTime<int>(duration: Duration(seconds: 5));
  ///
  /// timeBeacon.subscribe((values) {
  ///   print(values);
  /// });
  ///
  /// timeBeacon.value = 1;
  /// timeBeacon.value = 2;
  /// // After 5 seconds, it will output [1, 2]
  /// ```
  BufferedTimeBeacon<T> bufferedTime<T>({
    required Duration duration,
    String? name,
  }) =>
      BufferedTimeBeacon<T>(
        duration: duration,
        name: name ?? 'BufferedTimeBeacon<$T>',
      );

  /// Creates an `UndoRedoBeacon` with an initial value and an optional history limit.
  /// This beacon allows undoing and redoing changes to its value, up to the specified
  /// number of past states.
  ///
  /// This beacon is particularly useful in scenarios where you need to provide
  /// undo/redo functionality, such as in text editors or form input fields.
  ///
  /// Example:
  /// ```dart
  /// var undoRedoBeacon = UndoRedoBeacon<int>(0, historyLimit: 10);
  /// undoRedoBeacon.value = 10;
  /// undoRedoBeacon.value = 20;
  /// undoRedoBeacon.undo(); // Reverts to 10
  /// undoRedoBeacon.redo(); // Goes back to 20
  /// ```
  UndoRedoBeacon<T> undoRedo<T>(
    T initialValue, {
    int historyLimit = 10,
    String? name,
  }) {
    return UndoRedoBeacon<T>(
      initialValue: initialValue,
      historyLimit: historyLimit,
      name: name ?? 'UndoRedoBeacon<$T>',
    );
  }

  /// Like `Beacon.undoRedo` but behaves like a late variable. It must be set before it's read.
  ///
  /// Throws [UninitializeLazyReadException] if it's read before being set.
  UndoRedoBeacon<T> lazyUndoRedo<T>({
    T? initialValue,
    int historyLimit = 10,
    String? name,
  }) {
    return UndoRedoBeacon<T>(
      initialValue: initialValue,
      historyLimit: historyLimit,
      name: name ?? 'LazyUndoRedoBeacon<$T>',
    );
  }

  /// Creates a `TimestampBeacon` with an initial value.
  /// This beacon attaches a timestamp to each value update.
  ///
  /// Example:
  /// ```dart
  /// var myBeacon = Beacon.timestamped(10);
  /// print(myBeacon.value); // Outputs: (value: 10, timestamp: DateTime.now())
  /// ```
  TimestampBeacon<T> timestamped<T>(T initialValue, {String? name}) =>
      TimestampBeacon<T>(
        initialValue: initialValue,
        name: name ?? 'TimestampBeacon<$T>',
      );

  /// Like `Beacon.timestamped` but behaves like a late variable. It must be set before it's read.
  ///
  /// Throws [UninitializeLazyReadException] if it's read before being set.
  TimestampBeacon<T> lazyTimestamped<T>({
    T? initialValue,
    String? name,
  }) =>
      TimestampBeacon<T>(
        initialValue: initialValue,
        name: name ?? 'LazyTimestampBeacon<$T>',
      );

  /// Creates a `StreamBeacon` from a given stream.
  /// This beacon updates its value based on the stream's emitted values.
  /// The emitted values are wrapped in an `AsyncValue`, which can be in one of three states: loading, data, or error.
  ///
  /// Example:
  /// ```dart
  /// var myStream = Stream.periodic(Duration(seconds: 1), (i) => i);
  /// var myBeacon = Beacon.stream(myStream);
  /// myBeacon.subscribe((value) {
  ///   print(value); // Outputs the stream's emitted values
  /// });
  /// ```
  StreamBeacon<T> stream<T>(
    Stream<T> stream, {
    bool cancelOnError = false,
    String? name,
  }) {
    return StreamBeacon<T>(
      stream,
      cancelOnError: cancelOnError,
      name: name ?? 'StreamBeacon<$T>',
    );
  }

  /// Like `stream`, but it doesn't wrap the value in an `AsyncValue`.
  /// If you dont supply an initial value, the type has to be nullable.
  RawStreamBeacon<T> streamRaw<T>(
    Stream<T> stream, {
    bool cancelOnError = false,
    Function? onError,
    VoidCallback? onDone,
    T? initialValue,
    String? name,
  }) {
    return RawStreamBeacon<T>(
      stream,
      cancelOnError: cancelOnError,
      onError: onError,
      onDone: onDone,
      initialValue: initialValue,
      name: name ?? 'RawStreamBeacon<$T>',
    );
  }

  /// Creates a `FutureBeacon` that initializes its value based on a future.
  /// The beacon can optionally depend on another `ReadableBeacon`.
  ///
  /// If `manualStart` is `true`, the future will not execute until [start()] is called.
  ///
  /// Example:
  /// ```dart
  /// var myBeacon = Beacon.future(() async {
  ///   return await Future.delayed(Duration(seconds: 1), () => 'Hello');
  /// });
  /// myBeacon.subscribe((value) {
  ///   print(value); // Outputs 'Hello' after 1 second
  /// });
  /// ```
  FutureBeacon<T> future<T>(
    Future<T> Function() future, {
    bool manualStart = false,
    bool cancelRunning = true,
    String? name,
  }) {
    return DefaultFutureBeacon<T>(
      future,
      manualStart: manualStart,
      cancelRunning: cancelRunning,
      name: name ?? 'FutureBeacon<$T>',
    );
  }

  /// Creates a `DerivedBeacon` whose value is derived from a computation function.
  /// This beacon will recompute its value every time one of it's dependencies change.
  ///
  /// If `shouldSleep` is `true`(default), the callback will not execute if the beacon is no longer being watched.
  /// It will resume executing once a listener is added or it's value is accessed.
  ///
  /// If `supportConditional` is `true`(default), the effect look for its dependencies on its first run.
  /// This means once a beacon is added as a dependency, it will not be removed even if it's no longer used.
  /// Defaults to `true`.
  ///
  /// Example:
  /// ```dart
  /// final age = Beacon.writable<int>(18);
  /// final canDrink = Beacon.derived(() => age.value >= 21);
  ///
  /// print(canDrink.value); // Outputs: false
  ///
  /// age.value = 22;
  ///
  /// print(canDrink.value); // Outputs: true
  /// ```
  ReadableBeacon<T> derived<T>(
    T Function() compute, {
    String? name,
    bool shouldSleep = true,
    bool supportConditional = true,
  }) {
    final beacon = WritableDerivedBeacon<T>(
      name: name ?? 'DerivedBeacon<$T>',
      shouldSleep: shouldSleep,
    );

    void start() {
      final unsub = doEffect(
        () {
          beacon.set(compute());
        },
        supportConditional: supportConditional,
        name: name ?? 'DerivedBeacon<$T>',
      );

      beacon.$setInternalEffectUnsubscriber(unsub);
    }

    beacon.$setInternalEffectRestarter(start);

    start();

    return beacon;
  }

  /// Creates a `DerivedBeacon` whose value is derived from an asynchronous computation.
  /// This beacon will recompute its value every time one of its dependencies change.
  /// The result is wrapped in an `AsyncValue`, which can be in one of three states: loading, data, or error.
  ///
  /// If `manualStart` is `true`(default:false), the future will not execute until [start()] is called.
  ///
  /// If `cancelRunning` is `true`(default), the results of a current execution will be discarded
  /// if another execution is triggered before the current one finishes.
  ///
  /// If `shouldSleep` is `true`(default), the callback will not execute if the beacon is no longer being watched.
  /// It will resume executing once a listener is added or it's value is accessed.
  /// This means that it will enter the `loading` state when woken up.
  ///
  ///
  /// Example:
  /// ```dart
  ///   final counter = Beacon.writable(0);
  ///
  ///   // The future will be recomputed whenever the counter changes
  ///   final derivedFutureCounter = Beacon.derivedFuture(() async {
  ///     final count = counter.value;
  ///     await Future.delayed(Duration(seconds: count));
  ///     return '$count second has passed.';
  ///   });
  ///
  ///   class FutureCounter extends StatelessWidget {
  ///   const FutureCounter({super.key});
  ///
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     return switch (derivedFutureCounter.watch(context)) {
  ///       AsyncData<String>(value: final v) => Text(v),
  ///       AsyncError(error: final e) => Text('$e'),
  ///       AsyncLoading() => const CircularProgressIndicator(),
  ///     };
  ///   }
  /// }
  /// ```
  FutureBeacon<T> derivedFuture<T>(
    FutureCallback<T> compute, {
    bool manualStart = false,
    bool cancelRunning = true,
    bool shouldSleep = true,
    String? name,
  }) {
    final beacon = DerivedFutureBeacon<T>(
      compute,
      manualStart: manualStart,
      cancelRunning: cancelRunning,
      shouldSleep: shouldSleep,
      name: name ?? 'DerivedFutureBeacon<$T>',
    );

    final dispose = doEffect(
      () async {
        // beacon is manually triggered if in idle state
        if (beacon.status() == DerivedFutureStatus.idle) {
          return;
        }

        await beacon.run();
      },
      name: name ?? 'DerivedFutureBeacon<$T>',
    );

    beacon.$setInternalEffectUnsubscriber(dispose);

    return beacon;
  }

  /// Creates a `ListBeacon` with an initial list value.
  /// This beacon manages a list of items, allowing for reactive updates and manipulations of the list.
  ///
  /// The `ListBeacon` provides methods to add, remove, and update items in the list and notifies listeners without having to make a copy.
  ///
  /// NB: The `previousValue` and current value will always be the same because the same list is being mutated. If you need access to the previousValue, use Beacon.writable<List>([]) instead.
  ///
  /// Example:
  /// ```dart
  /// var nums = Beacon.list<int>([1, 2, 3]);
  ///
  /// Beacon.effect(() {
  ///  print(nums.value); // Outputs: [1, 2, 3]
  /// });
  ///
  /// nums.add(4); // Outputs: [1, 2, 3, 4]
  ///
  /// nums.remove(2); // Outputs: [1, 3, 4]
  /// ```
  ListBeacon<T> list<T>(List<T> initialValue, {String? name}) => ListBeacon<T>(
        initialValue,
        name: name ?? 'ListBeacon<$T>',
      );

  /// Creates a `SetBeacon` with an initial set value.
  /// This beacon manages a set of items, allowing for reactive updates and manipulations of the set.
  ///
  /// The `SetBeacon` provides methods to add, remove, and update items in the set and notifies listeners without having to make a copy.
  SetBeacon<T> hashSet<T>(Set<T> initialValue, {String? name}) => SetBeacon<T>(
        initialValue,
        name: name ?? 'SetBeacon<$T>',
      );

  /// Creates a `MapBeacon` with an initial map value.
  /// This beacon manages a map of items, allowing for reactive updates and manipulations of the map.
  ///
  /// The `MapBeacon` provides methods to add, remove, and update items in the map and notifies listeners without having to make a copy.
  MapBeacon<K, V> hashMap<K, V>(
    Map<K, V> initialValue, {
    String? name,
  }) =>
      MapBeacon<K, V>(
        initialValue,
        name: name ?? 'MapBeacon<$K,$V>',
      );

  /// Creates an effect based on a provided function. The provided function will be called
  /// whenever one of its dependencies change.
  ///
  /// If `supportConditional` is `false`, the effect look for its dependencies on its first run only.
  /// This means once a beacon is added as a dependency, it will not be removed even if it's no longer used
  /// and any beacon not accessed in the first run will not be tracked.
  /// Defaults to `true`.
  ///
  /// Example:
  /// ```dart
  /// final age = Beacon.writable(15);
  ///
  /// Beacon.effect(() {
  ///     if (age.value >= 18) {
  ///       print("You can vote!");
  ///     } else {
  ///        print("You can't vote yet");
  ///     }
  ///  });
  ///
  /// // Outputs: "You can't vote yet"
  ///
  /// age.value = 20; // Outputs: "You can vote!"
  /// ```
  VoidCallback effect(
    Function fn, {
    bool supportConditional = true,
    String? name,
  }) {
    return doEffect(
      fn,
      supportConditional: supportConditional,
      name: name,
    );
  }

  /// Creates an effect based on a provided function. The provided function will be called
  /// whenever one of its dependencies change.
  ///
  /// If `supportConditional` is `false`, the effect look for its dependencies on its first run only.
  /// This means once a beacon is added as a dependency, it will not be removed even if it's no longer used
  /// and any beacon not accessed in the first run will not be tracked.
  /// Defaults to `true`.
  ///
  /// Example:
  /// ```dart
  /// final age = Beacon.writable(15);
  ///
  /// Beacon.effect(() {
  ///     if (age.value >= 18) {
  ///       print("You can vote!");
  ///     } else {
  ///        print("You can't vote yet");
  ///     }
  ///  });
  ///
  /// // Outputs: "You can't vote yet"
  ///
  /// age.value = 20; // Outputs: "You can vote!"
  /// ```
  // coverage:ignore-start
  @Deprecated('Use Beacon.effect instead')
  VoidCallback createEffect(
    Function fn, {
    bool supportConditional = true,
    String? name,
  }) {
    return doEffect(
      fn,
      supportConditional: supportConditional,
      name: name,
    );
  }
  // coverage:ignore-end

  /// Executes a batched update which allows multiple updates to be batched into a single update.
  /// This can be used to optimize performance by reducing the number of update notifications.
  ///
  /// Example:
  /// ```dart
  /// final age = Beacon.writable<int>(10);
  ///
  /// var callCount = 0;
  ///
  /// age.subscribe((_) => callCount++);
  ///
  /// Beacon.batch(() {
  ///   age.value = 15;
  ///   age.value = 16;
  ///   age.value = 20;
  ///   age.value = 23;
  /// });
  ///
  /// expect(callCount, equals(1)); // There were 4 updates, but only 1 notification
  /// ```
  void batch(VoidCallback callback) {
    doBatch(callback);
  }

  /// Executes a batched update which allows multiple updates to be batched into a single update.
  /// This can be used to optimize performance by reducing the number of update notifications.
  ///
  /// Example:
  /// ```dart
  /// final age = Beacon.writable<int>(10);
  ///
  /// var callCount = 0;
  ///
  /// age.subscribe((_) => callCount++);
  ///
  /// Beacon.batch(() {
  ///   age.value = 15;
  ///   age.value = 16;
  ///   age.value = 20;
  ///   age.value = 23;
  /// });
  ///
  /// expect(callCount, equals(1)); // There were 4 updates, but only 1 notification
  /// ```
  // coverage:ignore-start
  @Deprecated('Use Beacon.batch instead')
  void doBatchUpdate(VoidCallback callback) {
    doBatch(callback);
  }
  // coverage:ignore-end

  /// Runs the function without tracking any changes to the state.
  /// This is useful when you want to run a function that
  /// changes the state, but you don't want to notify listeners of those changes.
  ///
  /// ```dart
  /// final age = Beacon.writable<int>(10);
  /// var callCount = 0;
  /// age.subscribe((_) => callCount++);
  ///
  /// Beacon.effect(() {
  ///      age.value;
  ///      Beacon.untracked(() {
  ///        age.value = 15;
  ///      });
  /// });
  ///
  /// expect(callCount, equals(0));
  /// expect(age.value, 15);
  /// ```
  void untracked(VoidCallback fn) {
    doUntracked(fn);
  }

  /// Creates and manages a family of related `Beacon`s based on a single creation function.
  ///
  /// This class provides a convenient way to handle related
  /// beacons that share the same creation logic but have different arguments.
  ///
  /// ### Type Parameters:
  ///
  /// * `T`: The type of the value emitted by the beacons in the family.
  /// * `Arg`: The type of the argument used to identify individual beacons within the family.
  /// * `BeaconType`: The type of the beacon in the family.
  ///
  /// If `cache` is `true`, created beacons are cached. Default is `false`.
  ///
  /// Example:
  /// ```dart
  ///final apiClientFamily = Beacon.family(
  ///  (String baseUrl) {
  ///    return Beacon.readable(ApiClient(baseUrl));
  ///  },
  ///);
  ///
  /// final githubApiClient = apiClientFamily('https://api.github.com');
  /// final twitterApiClient = apiClientFamily('https://api.twitter.com');
  /// ```
  BeaconFamily<Arg, BeaconType>
      family<T, Arg, BeaconType extends BaseBeacon<T>>(
    BeaconType Function(Arg) create, {
    bool cache = true,
  }) {
    return BeaconFamily<Arg, BeaconType>(create, shouldCache: cache);
  }
}
