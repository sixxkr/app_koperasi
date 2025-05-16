import 'dart:convert';
import 'package:app_koperasi/services/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_koperasi/services/auth_service.dart';

class KasirHome extends StatefulWidget {
  @override
  _KasirHomeState createState() => _KasirHomeState();
}

class _KasirHomeState extends State<KasirHome> {
  int? userId;
  String? kasirName;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOutOfStock();
      fetchTransaksi();
      loadUser();
    });
  }

  Future<void> _checkOutOfStock() async {
    final response = await http.get(Uri.parse('$baseUrl/produk'));

    if (response.statusCode == 200) {
      final List products = json.decode(response.body);

      final outOfStock = products.where((p) => p['stock'] == 0).toList();

      if (outOfStock.isNotEmpty) {
        final names = outOfStock.map((p) => p['nama']).join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Stok habis untuk: $names'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } else {
      print('Gagal mengambil data produk');
    }
  }

  Future<void> loadUser() async {
    userId = await AuthService.getUserId();
    if (userId != null) {
      final response = await http.get(Uri.parse('$baseUrl/profile/$userId'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          kasirName = data['name'];
        });
      }
    }
  }

  Future<void> fetchTransaksi() async {
    final response = await http.get(Uri.parse('$baseUrl/transaksi'));
    if (response.statusCode == 200) {
      final List transsaksi = json.decode(response.body);
      final status = transsaksi
          .where((element) =>
              element['status_pembayaran'] == "Menunggu Konfirmasi")
          .toList();

      if (status.isNotEmpty) {
        final names = status.map((element) => element['name']).join(', ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Transaksi baru dari : $names'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Selamat Datang${kasirName != null ? ', $kasirName' : ''}",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
