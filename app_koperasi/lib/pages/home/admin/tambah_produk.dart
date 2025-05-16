import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:app_koperasi/services/api.dart';

class TambahProdukPage extends StatefulWidget {
  @override
  _TambahProdukPageState createState() => _TambahProdukPageState();
}

class _TambahProdukPageState extends State<TambahProdukPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hargaController = TextEditingController();
  final TextEditingController _stokController = TextEditingController();

  int? _selectedCategory;
  File? _imageFile; // Menyimpan file gambar produk

  final Map<int, String> _categoryOptions = {
    1: 'Produk Dua Kelinci', // Contoh kategori
    2: 'Peralatan Rumah Tangga',
    3: 'Lainnya',
  };

  // Fungsi untuk memilih gambar dari galeri atau kamera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (_formKey.currentState!.validate()) {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
            '$baseUrl/add_produk'), // Ganti URL sesuai dengan API backend Anda
      );

      request.fields['nama'] = _nameController.text;
      request.fields['harga'] = _hargaController.text;
      request.fields['stock'] = _stokController.text;
      request.fields['id_kategori'] = _selectedCategory.toString();

      // Menambahkan gambar jika ada
      if (_imageFile != null) {
        request.files.add(await http.MultipartFile.fromPath(
          'gambar',
          _imageFile!.path,
        ));
      }

      // Mengirim request
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var result = jsonDecode(responseBody);

      if (response.statusCode == 200 && result['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Produk berhasil ditambahkan')),
        );
        Navigator.pop(context); // Kembali ke halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Terjadi kesalahan')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Produk')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nama Produk'),
                validator: (value) =>
                    value!.isEmpty ? 'Nama produk tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _hargaController,
                decoration: InputDecoration(labelText: 'Harga Produk'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Harga produk tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _stokController,
                decoration: InputDecoration(labelText: 'Stok Produk'),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Stok produk tidak boleh kosong' : null,
              ),
              DropdownButtonFormField<int>(
                value: _selectedCategory,
                decoration: InputDecoration(labelText: 'Kategori Produk'),
                items: _categoryOptions.entries.map((entry) {
                  return DropdownMenuItem<int>(
                    value: entry.key,
                    child: Text(entry.value),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) => value == null ? 'Pilih kategori' : null,
              ),
              SizedBox(height: 16),
              _imageFile != null
                  ? Image.file(
                      _imageFile!,
                      height: 150,
                      width: 150,
                      fit: BoxFit.cover,
                    )
                  : Text("Belum ada gambar yang dipilih"),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text("Pilih Gambar"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submit,
                child: Text('Simpan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
