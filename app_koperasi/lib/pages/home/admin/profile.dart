import 'package:app_koperasi/pages/home/admin/edit_profile.dart';
import 'package:flutter/material.dart';
import 'package:app_koperasi/services/auth_service.dart';

class ProfileAdmin extends StatefulWidget {
  @override
  final int userId;
  const ProfileAdmin({required this.userId});
  _ProfileAdminState createState() => _ProfileAdminState();
}

class _ProfileAdminState extends State<ProfileAdmin> {
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user =
        await AuthService().getProfile(widget.userId); // Ambil data dari API
    setState(() {
      _user = user;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_user == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    String? photoUrl = _user!['gambar_users']; // asumsi kolom bernama 'photo'
    bool hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    return Scaffold(
      appBar: AppBar(title: Text("Profil Pengguna")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Foto Profil
              CircleAvatar(
                radius: 50,
                backgroundImage: hasPhoto
                    ? NetworkImage(photoUrl)
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),
              SizedBox(height: 16),
              // Nama
              Text(
                _user!['name'] ?? 'Tidak ada nama',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              // Email
              Text(
                _user!['username'] ?? '',
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  final idUser = _user?['id_users'];
                  if (idUser != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfilePage(userId: idUser),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('ID User tidak ditemukan')),
                    );
                  }
                },
                child: Text("Edit Profil"),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  AuthService().logout(context);
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Logout'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
