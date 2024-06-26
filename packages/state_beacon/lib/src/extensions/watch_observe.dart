// ignore_for_file: invalid_use_of_protected_member, use_if_null_to_convert_nulls_to_bools, lines_longer_than_80_chars, deprecated_member_use

part of 'extensions.dart';

// ignore: public_member_api_docs
typedef ObserverCallback<T> = void Function(T prev, T next);

// coverage:ignore-start
// requires a manual GC trigger to test
final Finalizer<void Function()> _finalizer = Finalizer((fn) => fn());
// coverage:ignore-end

/// @macro WidgetUtils
extension WidgetUtils<T> on BaseBeacon<T> {
  /// Watches a beacon and triggers a widget
  /// rebuild when its value changes.
  ///
  /// Note: must be called within a widget's build method.
  ///
  /// Usage:
  /// ```dart
  /// final counter = Beacon.writable(0);
  ///
  /// class Counter extends StatelessWidget {
  ///  const Counter({super.key});
  ///
  ///  @override
  ///  Widget build(BuildContext context) {
  ///    final count = counter.watch(context);
  ///    return Text(count.toString());
  ///  }
  ///}
  /// ```
  T watch(BuildContext context) {
    final key = context.hashCode;

    return _watchOrObserve(
      key,
      context,
    );
  }

  /// Observes the state of a beacon and triggers a callback with the current state.
  ///
  /// The callback is provided with the current state of the beacon and a BuildContext.
  /// This can be used to show snackbars or other side effects.
  ///
  /// Usage:
  /// ```dart
  /// final exampleBeacon = Beacon.writable("Initial State");
  ///
  /// class ExampleWidget extends StatelessWidget {
  ///   @override
  ///   Widget build(BuildContext context) {
  ///     context.observe(exampleBeacon, (state, context) {
  ///       ScaffoldMessenger.of(context).showSnackBar(
  ///         SnackBar(content: Text(state)),
  ///       );
  ///     });
  ///     return Container();
  ///   }
  /// }
  /// ```
  void observe(
    BuildContext context,
    ObserverCallback<T> callback, {
    bool synchronous = false,
  }) {
    final key = Object.hash(
      context,
      'isObserving', // create 1 subscription for each widget
    );

    _watchOrObserve(
      key,
      context,
      callback: () => callback(previousValue as T, peek()),
      synchronous: synchronous,
    );
  }

  T _watchOrObserve(
    int key,
    BuildContext context, {
    VoidCallback? callback,
    bool synchronous = false,
  }) {
    if ($$widgetSubscribers$$.contains(key)) {
      return peek();
    }

    $$widgetSubscribers$$.add(key);

    final elementRef = WeakReference(context as Element);
    late VoidCallback unsub;

    void rebuildWidget() {
      elementRef.target!.markNeedsBuild();
    }

    final run = callback ?? rebuildWidget;

    void handleNewValue(T value) {
      if (elementRef.target?.mounted == true) {
        run();
      } else {
        unsub();
        $$widgetSubscribers$$.remove(key);
      }
    }

    unsub = subscribe(
      handleNewValue,
      startNow: false,
      synchronous: synchronous,
    );

    // coverage:ignore-start
    // clean up if the widget is disposed
    // and value is never modified again
    _finalizer.attach(
      context,
      () {
        unsub();
        $$widgetSubscribers$$.remove(key);
      },
    );
    // coverage:ignore-end

    return peek();
  }
}
