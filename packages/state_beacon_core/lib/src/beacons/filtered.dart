part of '../base_beacon.dart';

typedef BeaconFilter<T> = bool Function(T?, T);

class FilteredBeacon<T> extends WritableBeacon<T> {
  BeaconFilter<T>? _filter;

  FilteredBeacon(
      {super.initialValue, BeaconFilter<T>? filter, super.debugLabel})
      : _filter = filter;

  bool get hasFilter => _filter != null;

  // Set the function that will be used to filter subsequent values.
  void setFilter(BeaconFilter<T> newFilter) {
    _filter = newFilter;
  }

  @override
  set value(T newValue) => set(newValue);

  @override
  void set(T newValue, {bool force = false}) {
    if (_isEmpty || (_filter?.call(peek(), newValue) ?? true)) {
      super.set(newValue, force: force);
    }
  }
}