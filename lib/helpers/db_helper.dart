import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:path/path.dart';
import '../models/product_model.dart';

class DBHelper {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    String path;

    if (kIsWeb) {
      // Inisialisasi Database Factory khusus Web
      databaseFactory = databaseFactoryFfiWeb;
      path = 'app_database.db'; // Jalur database virtual untuk IndexedDB Web
    } else {
      if (defaultTargetPlatform == TargetPlatform.windows ||
          defaultTargetPlatform == TargetPlatform.linux ||
          defaultTargetPlatform == TargetPlatform.macOS) {
        // Inisialisasi Database Factory khusus Desktop
        sqfliteFfiInit();
        databaseFactory = databaseFactoryFfi;
      }
      final dbPath = await getDatabasesPath();
      path = join(dbPath, 'app_database.db');
    }

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        await _createTablesAndSeed(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          await _insertInitialProducts(db);
        }
      },
    );
  }

  Future<void> _createTablesAndSeed(Database db) async {
    await db.execute('''
      CREATE TABLE products(
        id TEXT PRIMARY KEY,
        name TEXT,
        price REAL,
        description TEXT,
        imageUrl TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE cart(
        id TEXT PRIMARY KEY,
        name TEXT,
        price REAL,
        description TEXT,
        imageUrl TEXT,
        quantity INTEGER
      )
    ''');

    await _insertInitialProducts(db);
  }

  Future<void> _insertInitialProducts(Database db) async {
    final initialProducts = [
      {
        'id': 'p1',
        'name': 'Laut Bercerita',
        'price': 150000.0,
        'description': 'Novel karya Leila S. Chudori',
        'imageUrl': 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1516602134i/36393774.jpg',
      },
      {
        'id': 'p2',
        'name': 'Bumi Manusia',
        'price': 170000.0,
        'description': 'Novel karya Pramoedya Ananta Toer',
        'imageUrl': 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1565658920i/1398034.jpg',
      },
      {
        'id': 'p3',
        'name': 'Hujan',
        'price': 90000.0,
        'description': 'Novel karya Tere Liye',
        'imageUrl': 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1451905281i/28446637.jpg',
      },
      {
        'id': 'p4',
        'name': 'Rumah Untuk Alie',
        'price': 120000.0,
        'description': 'Novel populer',
        'imageUrl': 'https://m.media-amazon.com/images/S/compressed.photo.goodreads.com/books/1715849329i/213533825.jpg',
      },
    ];

    for (var item in initialProducts) {
      await db.insert(
        'products',
        item,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
  }

  // --- CRUD PRODUK ---
  Future<void> insertProduct(Product product) async {
    final db = await database;
    await db.insert('products', {
      'id': product.id,
      'name': product.name,
      'price': product.price,
      'description': product.description,
      'imageUrl': product.imageUrl,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  // --- CRUD KERANJANG ---
  Future<void> insertCart(Product product) async {
    final db = await database;
    await db.insert('cart', product.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateCart(Product product) async {
    final db = await database;
    await db.update(
      'cart',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<void> deleteCart(String id) async {
    final db = await database;
    await db.delete('cart', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearCartTable() async {
    final db = await database;
    await db.delete('cart');
  }

  Future<List<Product>> getCart() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('cart');

    return List.generate(maps.length, (i) {
      return Product(
        id: maps[i]['id'].toString(),
        name: maps[i]['name'] ?? maps[i]['title'] ?? '',
        price: (maps[i]['price'] as num).toDouble(),
        description: maps[i]['description'] ?? '',
        imageUrl: maps[i]['imageUrl'] ?? '',
        quantity: maps[i]['quantity'] as int? ?? 1,
      );
    });
  }
}