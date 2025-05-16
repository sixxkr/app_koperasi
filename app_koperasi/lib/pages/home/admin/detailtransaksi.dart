// invoice_page.dart
import 'package:app_koperasi/services/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DetailTransaksiPage extends StatefulWidget {
  final int idTransaksi;

  DetailTransaksiPage({required this.idTransaksi});

  @override
  DetailTransaksiPageState createState() => DetailTransaksiPageState();
}

class DetailTransaksiPageState extends State<DetailTransaksiPage> {
  Map transaksi = {};
  List detail = [];

  @override
  void initState() {
    super.initState();
    fetchInvoice();
  }

  void fetchInvoice() async {
    final response = await http
        .get(Uri.parse('$baseUrl/transaksi/detail/${widget.idTransaksi}'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        transaksi = data['transaksi'];
        detail = data['detail'];
      });
    }
  }

  int getTotal() {
    return detail.fold(0, (sum, item) => sum + (item['subtotal'] as int));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Invoice")),
      body: transaksi.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                ListTile(
                  title: Text("Nama: ${transaksi['name']}"),
                  subtitle: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Agar teks rata kiri
                    children: [
                      Text("Transaksi #${transaksi['id_transaksi']}"),
                      Text(
                          "Status: ${transaksi['status_pembayaran']}"), // Menambahkan kalimat baru di bawah
                    ],
                  ),
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: detail.length,
                    itemBuilder: (context, index) {
                      final item = detail[index];
                      return ListTile(
                        leading: Image.network(
                            '$baseUrl/static/images/${item['gambar']}'),
                        title: Text(item['nama']),
                        subtitle: Text("Qty: ${item['jumlah']}"),
                        trailing: Text("Rp ${item['subtotal']}"),
                      );
                    },
                  ),
                ),
                ListTile(
                  title: Text("Status: ${transaksi['status_pembayaran']}"),
                  subtitle: Text("Total: Rp ${getTotal()}"),
                ),
              ],
            ),
    );
  }
}
