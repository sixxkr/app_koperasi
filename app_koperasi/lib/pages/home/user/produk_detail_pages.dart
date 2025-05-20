import 'dart:convert';
import 'package:app_koperasi/services/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'package:app_koperasi/pages/home/user/keranjang.dart';
import 'package:app_koperasi/services/auth_service.dart';
import 'package:app_koperasi/services/produk_service.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  final int productId;

  const ProductDetailPage({
    super.key,
    required this.productId,
  });

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  final produkService = ProdukService();
  Map<String, dynamic>? product;
  int? userId;
  int jumlah = 1;
  bool isLoading = true;
  String formatRupiah(dynamic angka) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(angka);
  }

  @override
  void initState() {
    super.initState();
    loadInitialData();
  }

  Future<void> loadInitialData() async {
    try {
      final int? id = await AuthService.getUserId();
      final data = await produkService.getProdukById(widget.productId);
      print("DEBUG: userId = $id");

      setState(() {
        userId = id;
        product = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat data: $e')),
      );
    }
  }

  Future<void> tambahKeKeranjang() async {
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User belum login')),
      );
      return;
    }

    final int harga = product!['harga'];
    final int subtotal = harga * jumlah;
    final response = await http.post(
      Uri.parse('$baseUrl/keranjang/tambah'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id_user': userId,
        'id_produk': widget.productId,
        'jumlah': jumlah,
        'subtotal': subtotal,
        'status': 'pending',
      }),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk ditambahkan ke keranjang')),
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => KeranjangPage(userId: userId!),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan ke keranjang')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Detail Produk")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : product == null
              ? const Center(child: Text("Produk tidak ditemukan"))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Gambar Produk
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(
                              '$baseUrl/static/images/${product!['gambar']}',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Nama dan Harga
                      Text(
                        product!['nama'],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        formatRupiah(product!['harga']),
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.green,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Stok: ${product!['stock']}"),
                      const SizedBox(height: 24),

                      // Jumlah Produk
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              if (jumlah > 1) {
                                setState(() => jumlah--);
                              }
                            },
                            icon: Icon(Icons.remove_circle_outline),
                          ),
                          Text(
                            jumlah.toString(),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              if (jumlah < product!['stock']) {
                                setState(() => jumlah++);
                              }
                            },
                            icon: Icon(Icons.add_circle_outline),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Tombol Tambah ke Keranjang
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: userId == null ? null : tambahKeKeranjang,
                          child: const Text("Tambah ke Keranjang"),
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
