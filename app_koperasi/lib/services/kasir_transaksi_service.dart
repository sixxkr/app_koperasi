import 'dart:convert';
import 'package:app_koperasi/services/api.dart';
import 'package:http/http.dart' as http;

class TransaksiKasir {
  final int idTransaksi;
  final int idUser;
  final int total;
  final String metodePembayaran;
  final String tanggal;
  final String namaUser;

  TransaksiKasir({
    required this.idTransaksi,
    required this.idUser,
    required this.total,
    required this.metodePembayaran,
    required this.tanggal,
    required this.namaUser,
  });

  factory TransaksiKasir.fromJson(Map<String, dynamic> json) {
    return TransaksiKasir(
      idTransaksi: json['id_transaksi'],
      idUser: json['id_user'],
      total: json['total'],
      metodePembayaran: json['metode_pembayaran'],
      tanggal: json['tanggal'],
      namaUser: json['nama_user'],
    );
  }
  Future<List<TransaksiKasir>> fetchSemuaTransaksi() async {
    final response = await http.get(Uri.parse('$baseUrl/transaksi'));

    if (response.statusCode == 200) {
      List jsonData = json.decode(response.body);
      return jsonData.map((item) => TransaksiKasir.fromJson(item)).toList();
    } else {
      throw Exception('Gagal memuat transaksi');
    }
  }
}
