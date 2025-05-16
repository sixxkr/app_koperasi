import 'package:app_koperasi/services/api.dart';
import 'package:flutter/material.dart';

class ProdukGrid extends StatelessWidget {
  final List<dynamic> produkList;
  final Function(int) onProductTapped;

  ProdukGrid({required this.produkList, required this.onProductTapped});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 0.75,
      ),
      itemCount: produkList.length,
      itemBuilder: (context, index) {
        final produk = produkList[index];
        return GestureDetector(
          onTap: () {
            if (produk['stock'] == 0) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Produk ini sedang habis")),
              );
              return;
            }
            onProductTapped(produk['id_produk']);
          },
          child: Card(
            elevation: 2,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(12)),
                    child: Image.network(
                      '$baseUrl/static/images/${produk!['gambar']}',
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          Icon(Icons.image),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(produk['nama'],
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      Text("Rp${produk['harga']}"),
                      produk['stock'] > 0
                          ? Text("Stok: ${produk['stock']}")
                          : Text(
                              "Out of Stock",
                              style: TextStyle(
                                  color: Colors.red,
                                  fontWeight: FontWeight.bold),
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
  }
}
