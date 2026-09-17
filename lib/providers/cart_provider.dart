import 'package:flutter/foundation.dart';
import '../helpers/db_helper.dart';
import '../models/product_model.dart';

class CartProvider with ChangeNotifier {
  List<Product> _cartItems = [];
  final DBHelper _dbHelper = DBHelper();

  List<Product> get cartItems => _cartItems;

  // 1. Memuat seluruh data keranjang dari database
  Future<void> fetchAndSetCart() async {
    _cartItems = await _dbHelper.getCartItems();
    notifyListeners();
  }

  // 2. Menambahkan produk ke keranjang
  Future<void> addToCart(Product product) async {
    final index = _cartItems.indexWhere((item) => item.id == product.id);

    if (index >= 0) {
      // Jika produk sudah ada, tambahkan kuantitasnya
      final updatedProduct = Product(
        id: product.id,
        name: product.name,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        quantity: _cartItems[index].quantity + 1,
      );
      
      await _dbHelper.updateCartQuantity(
        updatedProduct.id, 
        updatedProduct.quantity,
      );
      _cartItems[index] = updatedProduct;
    } else {
      // Jika produk belum ada, masukkan sebagai produk baru
      final newProduct = Product(
        id: product.id,
        name: product.name,
        price: product.price,
        description: product.description,
        imageUrl: product.imageUrl,
        quantity: 1,
      );

      await _dbHelper.insertCart(newProduct);
      _cartItems.add(newProduct);
    }
    notifyListeners();
  }

  // 3. Mengubah kuantitas item (tambah/kurang)
  Future<void> updateQuantity(String id, int newQuantity) async {
    if (newQuantity <= 0) {
      await removeItem(id);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.id == id);
    if (index >= 0) {
      await _dbHelper.updateCartQuantity(id, newQuantity);
      
      final currentItem = _cartItems[index];
      _cartItems[index] = Product(
        id: currentItem.id,
        name: currentItem.name,
        price: currentItem.price,
        description: currentItem.description,
        imageUrl: currentItem.imageUrl,
        quantity: newQuantity,
      );
      notifyListeners();
    }
  }

  // 4. Menghapus satu item dari keranjang
  Future<void> removeItem(String id) async {
    await _dbHelper.deleteCartItem(id);
    _cartItems.removeWhere((item) => item.id == id);
    notifyListeners();
  }

  // 5. Mengosongkan keranjang
  Future<void> clearCart() async {
    await _dbHelper.clearCartTable();
    _cartItems.clear();
    notifyListeners();
  }

  // Menghitung total harga seluruh isi keranjang
  double get totalPrice {
    return _cartItems.fold(
      0.0, 
      (sum, item) => sum + (item.price * item.quantity),
    );
  }
}