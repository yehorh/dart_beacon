// ignore_for_file: invalid_return_type_for_catch_error

import 'package:shopping_cart/src/models/models.dart';
import 'package:shopping_cart/src/models/product.dart';
import 'package:state_beacon/state_beacon.dart';

import 'events.dart';
import 'service.dart';

class CartController {
  CartController(this._cartService);

  final CartService _cartService;

  final _removingItem = Beacon.list<Product>([]);
  ReadableBeacon<List<Product>> get removingIndex => _removingItem;

  final _addingItem = Beacon.list<Product>([]);
  ReadableBeacon<List<Product>> get addingItem => _addingItem;

  late final _cart = Beacon.writable<AsyncValue<Cart>>(AsyncIdle());
  ReadableBeacon<AsyncValue<Cart>> get cart => _cart;

  Future<void> dispatch(CartEvent event) async {
    switch (event) {
      case CartStarted():
        await _cart.tryCatch(() => _cartService.loadProducts());

      case CartItemAdded(:final item):
        _addingItem.add(item);
        await _cart.tryCatch(() => _cartService.add(item));
        _addingItem.remove(item);

      case CartItemRemoved(:final item):
        _removingItem.add(item);
        await _cart.tryCatch(() => _cartService.remove(item));
        _removingItem.remove(item);
    }
  }
}
