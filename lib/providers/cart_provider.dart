import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  Map<String, CartItem> _items = {};
  final DBHelper _dbHelper = DBHelper();

  Map<String, CartItem> get items => {..._items};

  int get itemCount {
    int total = 0;
    _items.forEach((key, cartItem) {
      total += cartItem.quantity;
    });
    return total;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, cartItem) {
      total += cartItem.price * cartItem.quantity;
    });
    return total;
  }

  // Mengambil data keranjang dari SQLite saat aplikasi dibuka
  Future<void> fetchCartData() async {
    final cartList = await _dbHelper.getCart();
    final Map<String, CartItem> loadedItems = {};

    for (var item in cartList) {
      loadedItems[item.id] = CartItem(
        id: item.id,
        title: item.name,
        price: item.price.toDouble(),
        quantity: item.quantity,
        imageUrl: item.imageUrl,
      );
    }

    _items = loadedItems;
    notifyListeners();
  }

  // Menambah produk baru ke keranjang
  Future<void> addItem(String productId, double price, String title, String imageUrl) async {
    if (_items.containsKey(productId)) {
      final existing = _items[productId]!;
      final updatedItem = CartItem(
        id: existing.id,
        title: existing.title,
        price: existing.price,
        quantity: existing.quantity + 1,
        imageUrl: existing.imageUrl,
      );

      _items[productId] = updatedItem;

      await _dbHelper.updateCart(Product(
        id: productId,
        name: title,
        price: price,
        description: '',
        imageUrl: imageUrl,
        quantity: updatedItem.quantity,
      ));
    } else {
      final newItem = CartItem(
        id: productId,
        title: title,
        price: price,
        quantity: 1,
        imageUrl: imageUrl,
      );

      _items[productId] = newItem;

      await _dbHelper.insertCart(Product(
        id: productId,
        name: title,
        price: price,
        description: '',
        imageUrl: imageUrl,
        quantity: 1,
      ));
    }
    notifyListeners();
  }

  // Menambah jumlah (+1)
  Future<void> increaseItemQuantity(String productId) async {
    if (!_items.containsKey(productId)) return;

    final existing = _items[productId]!;
    final updatedItem = CartItem(
      id: existing.id,
      title: existing.title,
      price: existing.price,
      quantity: existing.quantity + 1,
      imageUrl: existing.imageUrl,
    );

    _items[productId] = updatedItem;

    await _dbHelper.updateCart(Product(
      id: productId,
      name: existing.title,
      price: existing.price,
      description: '',
      imageUrl: existing.imageUrl,
      quantity: updatedItem.quantity,
    ));

    notifyListeners();
  }

  // Mengurangi jumlah (-1), jika sisa 1 langsung dihapus
  Future<void> removeSingleItem(String productId) async {
    if (!_items.containsKey(productId)) return;

    final existing = _items[productId]!;

    if (existing.quantity > 1) {
      final updatedItem = CartItem(
        id: existing.id,
        title: existing.title,
        price: existing.price,
        quantity: existing.quantity - 1,
        imageUrl: existing.imageUrl,
      );

      _items[productId] = updatedItem;

      await _dbHelper.updateCart(Product(
        id: productId,
        name: existing.title,
        price: existing.price,
        description: '',
        imageUrl: existing.imageUrl,
        quantity: updatedItem.quantity,
      ));
    } else {
      _items.remove(productId);
      await _dbHelper.deleteCart(productId); // 👈 Gunakan _dbHelper.deleteCart
    }

    notifyListeners();
  }

  // Menghapus item dari keranjang
  Future<void> removeItem(String productId) async {
    if (!_items.containsKey(productId)) return;

    _items.remove(productId);
    await _dbHelper.deleteCart(productId); // 👈 Gunakan _dbHelper.deleteCart
    notifyListeners();
  }

  // Mengosongkan seluruh isi keranjang
  Future<void> clearCart() async {
    _items.clear();
    await _dbHelper.clearCartTable(); // 👈 Gunakan _dbHelper.clearCartTable
    notifyListeners();
  }
}