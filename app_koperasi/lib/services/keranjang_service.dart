import 'dart:convert';
import 'package:app_koperasi/services/api.dart';
import 'package:http/http.dart' as http;

class KeranjangService {
  Future<List<dynamic>> getKeranjang(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/keranjang/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal ambil keranjang');
    }
  }

  Future<void> hapusItem(int idCheckout) async {
    final response =
        await http.delete(Uri.parse('$baseUrl/keranjang/hapus/$idCheckout'));
    if (response.statusCode != 200) {
      throw Exception('Gagal hapus item');
    }
  }

  Future<void> prosesCheckout(int userId) async {
    final response =
        await http.put(Uri.parse('$baseUrl/keranjang/checkout/$userId'));
    if (response.statusCode != 200) {
      throw Exception('Gagal checkout');
    }
  }

  Future<List<dynamic>> getKeranjangwithStatus(int userId) async {
    final response =
        await http.get(Uri.parse('$baseUrl/keranjangwithstatus/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Gagal ambil keranjang');
    }
  }

  Future<bool> bayarCheckout({
    required int userId,
    required List<int> checkoutIds,
    required int total,
    required String metodePembayaran,
  }) async {
    final url = Uri.parse('$baseUrl/transaksi/bayar');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'id_user': userId,
        'id_checkout': checkoutIds,
        'total': total,
        'metode_pembayaran': metodePembayaran,
      }),
    );
    if (response.statusCode == 200) {
      return true;
    } else {
      print("Gagal membayar: ${response.body}");
      return false;
    }
  }
}
