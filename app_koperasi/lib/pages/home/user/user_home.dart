import 'package:app_koperasi/services/api.dart';
import 'package:flutter/material.dart';
import 'package:app_koperasi/services/produk_service.dart';
import 'package:app_koperasi/services/auth_service.dart';
import 'package:app_koperasi/pages/home/user/produk_detail_pages.dart';

class UserHome extends StatefulWidget {
  @override
  _UserHomeState createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final ProdukService produkService = ProdukService();
  List<dynamic> produkList = [];
  List<dynamic> bestsellerList = [];
  List<Map<String, dynamic>> categories = [
    {"id_kategori": 0, "nama": "Semua"}
  ];
  int selectedKategori = 0;
  String searchQuery = '';
  int? userId;

  @override
  void initState() {
    super.initState();
    fetchCategories();
    loadUserId();
  }

  Future<void> fetchCategories() async {
    try {
      final data = await produkService.getKategori();
      setState(() {
        categories = [
          {"id_kategori": 0, "nama": "Semua"},
          ...data
              .map((e) => {"id_kategori": e['id_kategori'], "nama": e['nama']})
        ];
      });
      fetchProduk();
      fetchBestSeller();
    } catch (e) {
      print('Failed to load categories: $e');
    }
  }

  Future<void> fetchProduk() async {
    try {
      List<dynamic> data;
      if (selectedKategori == 0) {
        data = await produkService.getProduk();
      } else {
        data = await produkService.getProdukByKategori(selectedKategori);
      }
      setState(() {
        produkList = data;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() {
        produkList = [];
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error loading products')));
    }
  }

  Future<void> fetchBestSeller() async {
    try {
      final data = await produkService.getBestSellerProduk();
      setState(() {
        bestsellerList = data;
      });
    } catch (e) {
      print('Error fetching bestsellers: $e');
    }
  }

  Future<void> loadUserId() async {
    final id = await AuthService.getUserId();
    setState(() {
      userId = id;
    });
  }

  void searchProdukList(String query) async {
    if (query.isEmpty) {
      fetchProduk();
    } else {
      final data = await produkService.searchProduk(query);
      setState(() {
        produkList = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 Search bar
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextField(
                onChanged: (value) {
                  searchProdukList(value);
                },
                decoration: InputDecoration(
                  hintText: "Cari produk...",
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            // 🏆 Best Seller Section (selalu ditampilkan jika ada)
            if (bestsellerList.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text("Best Seller",
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: bestsellerList.length,
                  itemBuilder: (context, index) {
                    final produk = bestsellerList[index];
                    return GestureDetector(
                      onTap: () {
                        if (produk['stock'] == 0) {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Produk ini sedang habis")));
                          return;
                        }
                        final productId = produk['id_produk'];
                        if (productId != null && productId is int) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ProductDetailPage(productId: productId)),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("ID produk tidak valid")));
                        }
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  '$baseUrl/static/images/${produk['gambar']}',
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
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text("Rp${produk['harga']}"),
                                  produk['stock'] > 0
                                      ? Text("Stok: ${produk['stock']}")
                                      : Text("Out of Stock",
                                          style: TextStyle(
                                              color: Colors.red,
                                              fontWeight: FontWeight.bold)),
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

            // 🎯 Filter dropdown & produk grid
            Padding(
              padding: const EdgeInsets.all(8),
              child: DropdownButton<int>(
                value: selectedKategori,
                onChanged: (newValue) {
                  setState(() {
                    selectedKategori = newValue!;
                  });
                  fetchProduk(); // Fetch produk berdasarkan kategori
                },
                items: categories.map<DropdownMenuItem<int>>((kategori) {
                  return DropdownMenuItem<int>(
                    value: kategori['id_kategori'],
                    child: Text(kategori['nama']),
                  );
                }).toList(),
              ),
            ),

            // Grid view of products
            if (produkList.isNotEmpty) ...[
              GridView.builder(
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
                            SnackBar(content: Text("Produk ini sedang habis")));
                        return;
                      }
                      final productId = produk['id_produk'];
                      if (productId != null && productId is int) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ProductDetailPage(productId: productId)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("ID produk tidak valid")));
                      }
                    },
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(12)),
                              child: Image.network(
                                '$baseUrl/static/images/${produk['gambar']}',
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
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                Text("Rp${produk['harga']}"),
                                produk['stock'] > 0
                                    ? Text("Stok: ${produk['stock']}")
                                    : Text("Out of Stock",
                                        style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ] else ...[
              Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                    child: Text("Produk tidak tersedia dalam kategori ini",
                        style: TextStyle(fontSize: 16, color: Colors.grey))),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
