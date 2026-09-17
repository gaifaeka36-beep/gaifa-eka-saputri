import 'package:flutter/material.dart';
import '../models/cart_item.dart';
import '../models/product.dart';
import '../helpers/db_helper.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};

  // Getter yang dibutuhkan oleh CartScreen
  Map<String, CartItem> get items => {..._items};

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  Future<void> fetchAndSetCart() async {
    final dataList = await DBHelper.getData('cart');
    final Map<String, CartItem> loadedItems = {};
    for (var item in dataList) {
      final cartItem = CartItem.fromMap(item);
      loadedItems[cartItem.id] = cartItem;
    }
    _items = loadedItems;
    notifyListeners();
  }

  Future<void> addItem(Product product) async {
    if (_items.containsKey(product.id)) {
      await increaseItemQuantity(product.id);
    } else {
      final newItem = CartItem(
        id: product.id,
        title: product.name,
        quantity: 1,
        price: product.price,
        imageUrl: product.imageUrl,
      );
      _items[product.id] = newItem;
      await DBHelper.insert('cart', newItem.toMap());
      notifyListeners();
    }
  }

  // Method untuk menambah jumlah item (+1)
  Future<void> increaseItemQuantity(String productId) async {
    if (!_items.containsKey(productId)) return;

    final existing = _items[productId]!;
    final updated = CartItem(
      id: existing.id,
      title: existing.title,
      quantity: existing.quantity + 1,
      price: existing.price,
      imageUrl: existing.imageUrl,
    );
    _items[productId] = updated;
    notifyListeners();
    await DBHelper.updateQuantity('cart', productId, updated.quantity);
  }

  // Method untuk mengurangi jumlah item (-1)
  Future<void> removeSingleItem(String productId) async {
    if (!_items.containsKey(productId)) return;

    if (_items[productId]!.quantity > 1) {
      final existing = _items[productId]!;
      final updated = CartItem(
        id: existing.id,
        title: existing.title,
        quantity: existing.quantity - 1,
        price: existing.price,
        imageUrl: existing.imageUrl,
      );
      _items[productId] = updated;
      await DBHelper.updateQuantity('cart', productId, updated.quantity);
    } else {
      _items.remove(productId);
      await DBHelper.delete('cart', productId);
    }
    notifyListeners();
  }

  Future<void> removeItem(String productId) async {
    _items.remove(productId);
    notifyListeners();
    await DBHelper.delete('cart', productId);
  }

  Future<void> clearCart() async {
    _items = {};
    notifyListeners();
    await DBHelper.clear('cart');
  }
}