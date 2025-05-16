import 'dart:convert';
import 'package:app_koperasi/pages/login_page.dart';
import 'package:app_koperasi/services/api.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class AuthService {
  Future<Map<String, dynamic>> login(String username, String password) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'username': username, 'password': password}),
    );

    return jsonDecode(res.body);
  }

  Future<String> register(
      String name, String username, String password, int role) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'username': username,
        'password': password,
        'role': role
      }),
    );

    return jsonDecode(res.body)['message'];
  }

  Future<Map<String, dynamic>?> getProfile(int userId) async {
    final response = await http.get(Uri.parse('$baseUrl/profile/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      print('Gagal ambil profile: ${response.body}');
      return null;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data,
      {File? imageFile}) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('id_users');
    final uri = Uri.parse('$baseUrl/users/update/$userId');

    var request = http.MultipartRequest('PUT', uri);
    request.fields['nama'] = data['nama'] ?? '';
    if (data['password'] != null && data['password'] != '') {
      request.fields['password'] = data['password'];
    }

    if (imageFile != null) {
      request.files.add(
          await http.MultipartFile.fromPath('gambar_users', imageFile.path));
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    return response.statusCode == 200;
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // hapus semua session

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginPage()),
      (Route<dynamic> route) => false, // Remove semua halaman sebelumnya
    );
  }

  Future<void> checkSession(int expectedRole, BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? isLoggedIn = prefs.getBool('isLoggedIn');
    int? role = prefs.getInt('role');

    if (isLoggedIn != true || role != expectedRole) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => LoginPage()),
        (Route<dynamic> route) => false,
      );
    }
  }

  static Future<int?> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? userId = prefs.getInt('id_users');
    return userId;
  }
}
