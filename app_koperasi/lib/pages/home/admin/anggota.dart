import 'dart:convert';
import 'package:app_koperasi/pages/home/admin/edit_anggota.dart';
import 'package:app_koperasi/pages/home/admin/tambah_anggota.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:app_koperasi/services/api.dart';

class ListAnggotaPage extends StatefulWidget {
  @override
  _ListAnggotaPageState createState() => _ListAnggotaPageState();
}

class _ListAnggotaPageState extends State<ListAnggotaPage> {
  List anggotaList = [];
  bool isLoading = true;

  Future<void> fetchAnggota() async {
    final response = await http.get(Uri.parse('$baseUrl/users'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        anggotaList = data;
        isLoading = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil data anggota')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    fetchAnggota();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daftar Anggota')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: anggotaList.length,
              itemBuilder: (context, index) {
                final anggota = anggotaList[index];
                return ListTile(
                  title: Text(anggota['name']),
                  subtitle: Text(anggota['username']),
                  trailing: Icon(Icons.edit),
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            EditAnggotaPage(userId: anggota['id_users']),
                      ),
                    );
                    fetchAnggota(); // refresh after return
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TambahAnggotaPage(),
            ),
          );
          fetchAnggota(); // refresh setelah tambah
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.blueAccent,
        tooltip: 'Tambah Anggota',
      ),
    );
  }
}
