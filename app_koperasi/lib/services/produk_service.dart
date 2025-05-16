import 'dart:convert';
import 'package:app_koperasi/services/api.dart';
import 'package:http/http.dart' as http;

class ProdukService {
  Future<List<dynamic>> getProduk() async {
    final res = await http.get(Uri.parse('$baseUrl/produk'));
    return jsonDecode(res.body);
  }

  Future<Map<String, dynamic>> getProdukById(int id) async {
    final url = Uri.parse('$baseUrl/produk/$id');

    final response = await http.get(url);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Produk tidak ditemukan (status ${response.statusCode})');
    }
  }

  Future<List<dynamic>> getBestSellerProduk() async {
    final response = await http.get(Uri.parse('$baseUrl/produk/best_seller'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat produk best seller');
    }
  }

  Future<List<dynamic>> getProdukByKategori(int kategoriId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/produk/kategori/$kategoriId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Produk tidak ditemukan');
    } else {
      throw Exception('Gagal mengambil produk berdasarkan kategori');
    }
  }

  Future<List<dynamic>> searchProduk(String query) async {
    final response = await http.get(Uri.parse('$baseUrl/produk/search/$query'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal memuat hasil pencarian');
    }
  }

  Future<List<Map<String, dynamic>>> getKategori() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/kategori'));
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => Map<String, dynamic>.from(item)).toList();
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }
}
