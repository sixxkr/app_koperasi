import 'dart:convert';
import 'dart:typed_data';

import 'package:app_koperasi/services/api.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'dart:io' as io; // untuk mobile
// untuk web

class EditProdukPage extends StatefulWidget {
  final int idProduk;

  EditProdukPage({required this.idProduk});

  @override
  _EditProdukPageState createState() => _EditProdukPageState();
}

class _EditProdukPageState extends State<EditProdukPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController namaController = TextEditingController();
  TextEditingController stockController = TextEditingController();
  TextEditingController hargaController = TextEditingController();
  TextEditingController kategoriController = TextEditingController();

  Uint8List? _imageBytes;
  String? _namaFileGambar;
  String? _gambarBase64;
  final String apiUrl = '$baseUrl/produk';

  @override
  void initState() {
    super.initState();
    fetchProduk();
  }

  Future<void> fetchProduk() async {
    final response = await http.get(Uri.parse('$apiUrl/${widget.idProduk}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        namaController.text = data['nama'];
        stockController.text = data['stock'].toString();
        hargaController.text = data['harga'].toString();
        kategoriController.text = data['id_kategori'].toString();
        _namaFileGambar = data['gambar'];
      });
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _gambarBase64 = base64Encode(bytes);
        });
      } else {
        final file = io.File(pickedFile.path);
        final bytes = await file.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _gambarBase64 = base64Encode(bytes);
        });
      }
    }
  }

  Future<void> updateProduk() async {
    final data = {
      'nama': namaController.text,
      'stock': stockController.text,
      'harga': hargaController.text,
      'id_kategori': kategoriController.text,
      'gambar_base64': _gambarBase64,
    };

    final response = await http.put(
      Uri.parse('$apiUrl/${widget.idProduk}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Produk berhasil diupdate')),
      );
      Navigator.pop(context);
    } else {
      print('Gagal update produk');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Produk')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: namaController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
              ),
              TextFormField(
                controller: stockController,
                decoration: InputDecoration(labelText: 'Stok'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: hargaController,
                decoration: InputDecoration(labelText: 'Harga'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: kategoriController,
                decoration: InputDecoration(labelText: 'ID Kategori'),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              _imageBytes != null
                  ? Image.memory(_imageBytes!, height: 100)
                  : _namaFileGambar != null
                      ? Image.network('$baseUrl/static/images/$_namaFileGambar',
                          height: 100)
                      : Container(),
              ElevatedButton(
                onPressed: pickImage,
                child: Text('Pilih Gambar'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: updateProduk,
                child: Text('Simpan Perubahan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
