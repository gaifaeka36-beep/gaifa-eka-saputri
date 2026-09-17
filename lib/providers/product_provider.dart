import 'package:flutter/material.dart';
import '../helpers/db_helper.dart';
import '../models/product_model.dart';

class ProductProvider with ChangeNotifier {
  List<Product> _products = [];
  final DBHelper _dbHelper = DBHelper();

  List<Product> get products => [..._products];

  // Data default jika SQLite masih kosong
  final List<Product> _initialProducts = [
    Product(
      id: 'p1',
      name: 'Laut Bercerita',
      price: 150000,
      description: 'Novel karya Leila S. Chudori',
      imageUrl: 'https://m.media-amazon.com/images/I/81x2g4N8-qL._AC_UF1000,1000_QL80_.jpg',
    ),
    Product(
      id: 'p2',
      name: 'Bumi Manusia',
      price: 170000,
      description: 'Novel karya Pramoedya Ananta Toer',
      imageUrl: 'https://m.media-amazon.com/images/I/81A-P1M8YvL._AC_UF1000,1000_QL80_.jpg',
    ),
    Product(
      id: 'p3',
      name: 'Hujan',
      price: 90000,
      description: 'Novel karya Tere Liye',
      imageUrl: 'https://m.media-amazon.com/images/I/71R2nN6a3mL._AC_UF1000,1000_QL80_.jpg',
    ),
    Product(
      id: 'p4',
      name: 'Rumah Untuk Alie',
      price: 120000,
      description: 'Novel populer',
      imageUrl: 'https://m.media-amazon.com/images/I/81R93Q+B5rL._AC_UF1000,1000_QL80_.jpg',
    ),
  ];

  // Fetch seluruh produk dari SQLite
  Future<void> fetchAllData() async {
    final dbProducts = await _dbHelper.getProducts();

    if (dbProducts.isEmpty) {
      for (var item in _initialProducts) {
        await _dbHelper.insertProduct(item);
      }
      _products = await _dbHelper.getProducts();
    } else {
      _products = dbProducts;
    }

    notifyListeners();
  }

  // Menambah produk baru ke SQLite dan State
  Future<void> addProduct(String name, double price, String imageUrl, {String description = ''}) async {
    final newProduct = Product(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      description: description,
      imageUrl: imageUrl,
    );

    await _dbHelper.insertProduct(newProduct);
    _products.add(newProduct);
    notifyListeners();
  }

  // Menghapus produk dari katalog
  Future<void> deleteProduct(String id) async {
    await _dbHelper.deleteProduct(id);
    _products.removeWhere((prod) => prod.id == id);
    notifyListeners();
  }

  // Mencari produk berdasarkan ID
  Product findById(String id) {
    return _products.firstWhere((prod) => prod.id == id);
  }
}