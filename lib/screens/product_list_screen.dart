import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      await Provider.of<ProductProvider>(context, listen: false).fetchAllData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Pop-up Dialog untuk Tambah Produk Baru
  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tambah Produk Baru'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama Buku'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Harga'),
              ),
              TextField(
                controller: imageController,
                decoration: const InputDecoration(
                  labelText: 'URL Gambar',
                  hintText: 'https://...',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            onPressed: () {
              if (nameController.text.isEmpty ||
                  priceController.text.isEmpty ||
                  imageController.text.isEmpty) {
                return;
              }
              Provider.of<ProductProvider>(context, listen: false).addProduct(
                nameController.text,
                double.parse(priceController.text),
                imageController.text,
              );
              Navigator.of(ctx).pop();
            },
            child: const Text('Simpan', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFD32F2F);
    const Color bgCream = Color(0xFFFFF8E7);
    const Color buttonBg = Color(0xFFFFF3E0);
    const Color buttonBorder = Color(0xFFE65100);

    return Scaffold(
      backgroundColor: bgCream,
      appBar: AppBar(
        backgroundColor: primaryRed,
        elevation: 0,
        title: const Text(
          'NOVELKU GFAMEDIA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        actions: [
          IconButton(
            icon: Image.network(
              'https://cdn-icons-png.flaticon.com/512/1170/1170678.png',
              width: 28,
              height: 28,
              errorBuilder: (_, __, ___) =>
                  const Icon(Icons.shopping_cart, color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (ctx) => const CartScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Baris Pencarian
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.red.shade400, width: 1),
              ),
              child: Row(
                children: [
                  Container(
                    width: 32,
                    height: 40,
                    color: primaryRed,
                    child: const Icon(Icons.search, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val.toLowerCase();
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Pencarian',
                        hintStyle: TextStyle(color: Colors.grey, fontSize: 13),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Daftar Katalog Produk
          Expanded(
            child: Consumer<ProductProvider>(
              builder: (ctx, productData, child) {
                final filteredProducts = productData.products.where((prod) {
                  return prod.name.toLowerCase().contains(_searchQuery);
                }).toList();

                if (filteredProducts.isEmpty) {
                  return const Center(
                    child: Text('Buku tidak ditemukan'),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: filteredProducts.length,
                  itemBuilder: (ctx, i) {
                    final product = filteredProducts[i];

                    String imageUrl = product.imageUrl.trim();
                    if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
                      imageUrl = 'https://$imageUrl';
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 4,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            // Gambar Cover Buku
                            SizedBox(
                              width: 65,
                              height: 85,
                              child: Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey.shade300,
                                    child: const Icon(Icons.book, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Detail Nama & Harga
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    product.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Rp ${product.price.toStringAsFixed(0)}',
                                    style: const TextStyle(
                                      color: buttonBorder,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Tombol Tambah ke Keranjang
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                backgroundColor: buttonBg,
                                side: const BorderSide(color: primaryRed, width: 1),
                                shape: const RoundedRectangleBorder(
                                  borderRadius: BorderRadius.zero,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                              ),
                              onPressed: () {
                                Provider.of<CartProvider>(context, listen: false).addItem(
                                  product.id,
                                  product.price,
                                  product.name,
                                  product.imageUrl,
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${product.name} masuk keranjang'),
                                    duration: const Duration(seconds: 1),
                                  ),
                                );
                              },
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.shopping_cart_outlined,
                                    color: Colors.black,
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text(
                                    'Tambah',
                                    style: TextStyle(
                                      color: buttonBorder,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Tombol Floating "+ Tambah produk"
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryRed,
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          onPressed: () => _showAddProductDialog(context),
          icon: const Icon(Icons.add, color: Colors.white, size: 20),
          label: const Text(
            'Tambah produk',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),

      // Navigasi Bawah Merah/Kuning
      bottomNavigationBar: Container(
        height: 50,
        color: primaryRed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _selectedIndex == 0 ? Colors.yellow : Colors.white,
                size: 28,
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 0;
                });
              },
            ),
            IconButton(
              icon: Icon(
                Icons.shopping_cart,
                color: _selectedIndex == 1 ? Colors.yellow : Colors.white,
                size: 28,
              ),
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => const CartScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}