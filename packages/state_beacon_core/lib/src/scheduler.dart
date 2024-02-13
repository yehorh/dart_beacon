part of 'producer.dart';

final _effectQueue = Queue<Consumer>();
void Function() _stabilizeFn = _asyncScheduler;
bool _stabilizationQueued = false;

/// Whether the scheduler is in synchronous mode
bool isSynchronousMode = _stabilizeFn == _syncScheduler;

/// A class for configuring the scheduler
abstract class BeaconScheduler {
  /// Returns a future that completes when all queued effects have been flushed
  static Future<void> settle([Duration duration = Duration.zero]) =>
      Future.delayed(duration);

  /// Runs all queued effects/subscriptions
  /// This is made available for testing and should not be used in production
  static void flush() => _flushEffects();

  /// Sets the scheduler to the provided function
  static void setScheduler(void Function() fn) => _stabilizeFn = fn;

  /// This is the default scheduler which processes updates asynchronously
  /// as a DartVM microtask. This does automatic batching of updates.
  static void useAsyncScheduler() {
    isSynchronousMode = false;
    _stabilizeFn = _asyncScheduler;
  }

  /// This scheduler processes updates synchronously. This is not recommended
  /// for production apps and only provided to make testing easier.
  ///
  /// With this scheduler, you aren't protected from stackoverflows when
  /// an effect mutates a beacon that it depends on. This is a infinite loop
  /// with the sync scheduler.
  static void useSyncScheduler() {
    isSynchronousMode = true;
    _stabilizeFn = _syncScheduler;
  }
}

void _flushEffects() {
  // final len = effectQueue.length;
  // var i = 0;
  // while (i < len) {
  //   effectQueue[i].updateIfNecessary();
  //   i++;
  // }
  // effectQueue.clear();

  // the above code (and for loop) results in concurrent modification error
  // and/or partial flushes
  while (_effectQueue.isNotEmpty) {
    _effectQueue.removeFirst().updateIfNecessary();
  }
}

void _asyncScheduler() {
  if (!_stabilizationQueued) {
    _stabilizationQueued = true;
    Future.microtask(() {
      _flushEffects();
      _stabilizationQueued = false;
    });
  }
}

void _syncScheduler() {
  if (!_stabilizationQueued) {
    _stabilizationQueued = true;
    _flushEffects();
    _stabilizationQueued = false;
  }
}
