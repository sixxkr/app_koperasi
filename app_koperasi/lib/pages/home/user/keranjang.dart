import 'package:app_koperasi/services/api.dart';
import 'package:flutter/material.dart';
import '../../../services/keranjang_service.dart';

class KeranjangPage extends StatefulWidget {
  final int userId;

  const KeranjangPage({required this.userId});

  @override
  _KeranjangPageState createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List<dynamic> keranjang = [];
  final service = KeranjangService();

  @override
  void initState() {
    super.initState();
    fetchKeranjang();
  }

  Future<void> fetchKeranjang() async {
    try {
      final data = await service.getKeranjang(widget.userId);
      setState(() {
        keranjang = data;
      });
    } catch (e) {
      print(e);
    }
  }

  Future<void> hapusItem(int idCheckout) async {
    await service.hapusItem(idCheckout);
    fetchKeranjang();
  }

  Future<void> prosesCheckout() async {
    await service.prosesCheckout(widget.userId);
    fetchKeranjang();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Checkout berhasil!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Keranjang Saya')),
      body: keranjang.isEmpty
          ? Center(child: Text('Keranjang kosong'))
          : ListView.builder(
              itemCount: keranjang.length,
              itemBuilder: (context, index) {
                final item = keranjang[index];
                return ListTile(
                  leading: Image.network(
                    '$baseUrl/static/images/${item['gambar']}',
                    width: 50,
                  ),
                  title: Text(item['nama']),
                  subtitle: Text('Jumlah: ${item['jumlah']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Rp${item['subtotal']}'),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => hapusItem(item['id_checkout']),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: keranjang.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: prosesCheckout,
              icon: Icon(Icons.shopping_cart_checkout),
              label: Text('Checkout'),
            )
          : null,
    );
  }
}
