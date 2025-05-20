import 'dart:convert';
import 'package:app_koperasi/pages/home/admin/edit_barang.dart';
import 'package:app_koperasi/services/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class BarangAdmin extends StatefulWidget {
  @override
  _BarangAdminPageState createState() => _BarangAdminPageState();
}

class _BarangAdminPageState extends State<BarangAdmin> {
  List produkList = [];
  bool isLoading = true;
  String formatRupiah(dynamic angka) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(angka);
  }

  Future<void> fetchProduk() async {
    final response = await http.get(Uri.parse('$baseUrl/produk'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        produkList = data;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data produk')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Produk')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: produkList.length,
              itemBuilder: (context, index) {
                final produk = produkList[index];
                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: produk['gambar'] != null
                        ? Image.network(
                            '$baseUrl/static/images/${produk['gambar']}',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.image, size: 50),
                    title: Text(produk['nama']),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Harga: ${formatRupiah(produk['harga'])}'),
                        produk['stock'] > 0
                            ? Text("Stok: ${produk['stock']}")
                            : Text(
                                "Out of Stock",
                                style: TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.bold),
                              )
                      ],
                    ),
                    trailing: Icon(Icons.edit),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditProdukPage(idProduk: produk['id_produk']),
                        ),
                      ).then((_) => fetchProduk());
                    },
                  ),
                );
              },
            ),
    );
  }
}
