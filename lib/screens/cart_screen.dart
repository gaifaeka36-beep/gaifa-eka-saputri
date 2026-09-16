import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color primaryRed = Color(0xFFD32F2F);
    const Color bgOrange = Color(0xFFFFF3E0);

    return Scaffold(
      backgroundColor: bgOrange,
      appBar: AppBar(
        backgroundColor: primaryRed,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Consumer<CartProvider>(
          builder: (_, cart, __) => Text(
            'Keranjang Belanja (${cart.itemCount})',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Consumer<CartProvider>(
        builder: (context, cart, child) {
          final cartItemsList = cart.items.values.toList();
          final productIds = cart.items.keys.toList();

          return Column(
            children: [
              // Ringkasan Total Pembayaran
              Card(
                elevation: 2,
                color: const Color(0xFFFFF59D),
                margin: const EdgeInsets.all(12),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        color: primaryRed,
                        child: Text(
                          'Rp ${cart.totalAmount.toStringAsFixed(0)}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // List Item Keranjang
              Expanded(
                child: cart.items.isEmpty
                    ? const Center(
                        child: Text(
                          'Keranjang Anda kosong',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemCount: cart.items.length,
                        itemBuilder: (ctx, i) {
                          final item = cartItemsList[i];
                          final productId = productIds[i];

                          return Card(
                            elevation: 2,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Row(
                                children: [
                                  // Gambar Produk
                                  ClipRRect(
                                    borderRadius: BorderRadius.zero,
                                    child: Image.network(
                                      item.imageUrl.startsWith('http')
                                          ? item.imageUrl
                                          : 'https://${item.imageUrl}',
                                      width: 60,
                                      height: 80,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (ctx, error, stackTrace) => Container(
                                        width: 60,
                                        height: 80,
                                        color: const Color(0xFFFFE0B2),
                                        child: const Icon(
                                          Icons.book,
                                          size: 30,
                                          color: primaryRed,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),

                                  // Judul & Total Harga Produk
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          'Total : Rp ${(item.price * item.quantity).toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Color(0xFFE65100),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Tombol Pengatur Jumlah Kuantitas (+ / -)
                                  Container(
                                    color: const Color(0xFFFF9800),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.remove,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            cart.removeSingleItem(productId);
                                          },
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                        IconButton(
                                          constraints: const BoxConstraints(
                                            minWidth: 32,
                                            minHeight: 32,
                                          ),
                                          padding: EdgeInsets.zero,
                                          icon: const Icon(
                                            Icons.add,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          onPressed: () {
                                            cart.increaseItemQuantity(productId);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
