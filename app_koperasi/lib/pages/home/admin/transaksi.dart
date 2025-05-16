import 'package:app_koperasi/pages/home/admin/detailtransaksi.dart';
import 'package:app_koperasi/services/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TransaksiAdmin extends StatefulWidget {
  @override
  _TransaksiAdminState createState() => _TransaksiAdminState();
}

class _TransaksiAdminState extends State<TransaksiAdmin> {
  List transaksi = [];

  @override
  void initState() {
    super.initState();
    fetchTransaksi();
  }

  Future<void> fetchTransaksi() async {
    final response = await http.get(Uri.parse('$baseUrl/transaksi'));
    if (response.statusCode == 200) {
      setState(() {
        transaksi = json.decode(response.body);
      });
    }
  }

  void ubahStatus(int idTransaksi, String statusBaru) async {
    final response = await http.put(
      Uri.parse('$baseUrl/transaksi/$idTransaksi/status'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'status': statusBaru}),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Status diperbarui')));
      fetchTransaksi();
    }
  }

  Color getBadgeColor(String status) {
    switch (status) {
      case 'Selesai':
        return Colors.green;
      case 'Dibatalkan':
        return Colors.red;
      case 'Menunggu Konfirmasi':
      default:
        return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Semua Transaksi')),
      body: ListView.builder(
        itemCount: transaksi.length,
        itemBuilder: (context, index) {
          var item = transaksi[index];
          bool bisaDiubah = item['status_pembayaran'] == 'Menunggu Konfirmasi';
          Color badgeColor = getBadgeColor(item['status_pembayaran']);

          return Card(
            child: ListTile(
              title: Text('User: ${item['name']}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Transaksi #${item['id_transaksi']}"),
                  const SizedBox(height: 4),
                  Text('Metode: ${item['metode_pembayaran']}'),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text('Status: '),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['status_pembayaran'],
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: bisaDiubah
                  ? PopupMenuButton<String>(
                      onSelected: (value) {
                        ubahStatus(item['id_transaksi'], value);
                      },
                      itemBuilder: (_) => ['Dibatalkan', 'Selesai']
                          .map((e) => PopupMenuItem(value: e, child: Text(e)))
                          .toList(),
                    )
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        DetailTransaksiPage(idTransaksi: item['id_transaksi']),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
