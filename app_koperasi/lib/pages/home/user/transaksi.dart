import 'package:app_koperasi/pages/home/user/invoice.dart';
import 'package:app_koperasi/services/api.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../services/keranjang_service.dart';

class TransaksiPage extends StatefulWidget {
  final int userId;

  TransaksiPage({required this.userId});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  List transaksiList = [];
  List keranjangSiapBayar = [];
  final service = KeranjangService();
  Set<int> selectedCheckoutIds = {};
  String metodePembayaran = "Cash";

  bool isLoadingTransaksi = true;
  bool isLoadingKeranjang = true;

  @override
  void initState() {
    super.initState();
    fetchTransaksi();
    fetchKeranjangSiapBayar();
  }

  static List<dynamic> parseJson(String responseBody) {
    return json.decode(responseBody);
  }

  Future<void> hapusItem(int idCheckout) async {
    await service.hapusItem(idCheckout);
    fetchKeranjangSiapBayar();
  }

  void fetchTransaksi() async {
    setState(() => isLoadingTransaksi = true);
    final response =
        await http.get(Uri.parse('$baseUrl/transaksi/${widget.userId}'));
    if (response.statusCode == 200) {
      final data = await compute(parseJson, response.body);
      setState(() {
        transaksiList = data;
        isLoadingTransaksi = false;
      });
    } else {
      print("Gagal ambil transaksi: ${response.statusCode}");
      setState(() => isLoadingTransaksi = false);
    }
  }

  void fetchKeranjangSiapBayar() async {
    setState(() => isLoadingKeranjang = true);
    final response = await http
        .get(Uri.parse('$baseUrl/keranjangwithstatus/${widget.userId}'));
    if (response.statusCode == 200) {
      final data = await compute(parseJson, response.body);
      setState(() {
        keranjangSiapBayar = data;
        isLoadingKeranjang = false;
      });
    } else {
      print("Gagal ambil keranjang siap bayar: ${response.statusCode}");
      setState(() => isLoadingKeranjang = false);
    }
  }

  int getTotal() {
    int total = 0;
    for (var item in keranjangSiapBayar) {
      if (selectedCheckoutIds.contains(item['id_checkout'])) {
        total += int.tryParse(item['subtotal'].toString()) ?? 0;
      }
    }
    return total;
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

  Future<void> updateStatusTransaksi(int idTransaksi, String status) async {
    final url = Uri.parse('$baseUrl/transaksi/$idTransaksi/status');
    try {
      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Status diperbarui')),
        );
        fetchTransaksi();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['message'] ?? 'Gagal update status')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Transaksi")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoadingKeranjang)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (keranjangSiapBayar.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("Transaksi Belum Dibayar",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: keranjangSiapBayar.length,
                itemBuilder: (context, index) {
                  final item = keranjangSiapBayar[index];
                  return CheckboxListTile(
                    value: selectedCheckoutIds.contains(item['id_checkout']),
                    onChanged: (bool? selected) {
                      setState(() {
                        if (selected == true) {
                          selectedCheckoutIds.add(item['id_checkout']);
                        } else {
                          selectedCheckoutIds.remove(item['id_checkout']);
                        }
                      });
                    },
                    title: Text(item['nama_produk'] ?? 'Nama Produk'),
                    subtitle: Text(
                        'Jumlah: ${item['jumlah']} - Subtotal: Rp ${item['subtotal']}'),
                    secondary: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => hapusItem(item['id_checkout']),
                    ),
                  );
                },
              ),
              if (selectedCheckoutIds.isNotEmpty) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: DropdownButton<String>(
                    value: metodePembayaran,
                    onChanged: (String? newValue) {
                      setState(() {
                        metodePembayaran = newValue!;
                      });
                    },
                    items: ['Cash']
                        .map((method) => DropdownMenuItem<String>(
                              value: method,
                              child: Text(method),
                            ))
                        .toList(),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
                  child: Text(
                    "Total: Rp ${getTotal()}",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await service.bayarCheckout(
                        userId: widget.userId,
                        checkoutIds: selectedCheckoutIds.toList(),
                        total: getTotal(),
                        metodePembayaran: metodePembayaran,
                      );
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text("Transaksi berhasil dibuat")));
                        selectedCheckoutIds.clear();
                        fetchKeranjangSiapBayar();
                        fetchTransaksi();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Gagal membuat transaksi")));
                      }
                    },
                    child: Text("Bayar"),
                  ),
                ),
              ],
              Divider(thickness: 2),
            ],
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text("Riwayat Transaksi",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            if (isLoadingTransaksi)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (transaksiList.isNotEmpty) ...[
              ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: transaksiList.length,
                itemBuilder: (context, index) {
                  final transaksi = transaksiList[index];
                  final status =
                      transaksi['status_pembayaran'] ?? 'Status tidak tersedia';
                  final metodePembayaran =
                      transaksi['metode_pembayaran'] ?? 'Metode tidak tersedia';
                  return ListTile(
                    title: Text("Transaksi #${transaksi['id_transaksi']}"),
                    subtitle: Row(
                      children: [
                        Text("Status: "),
                        Container(
                          padding:
                              EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: getBadgeColor(status),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(metodePembayaran),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => InvoicePage(
                              idTransaksi: transaksi['id_transaksi']),
                        ),
                      );
                    },
                  );
                },
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text("Belum ada transaksi.",
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
