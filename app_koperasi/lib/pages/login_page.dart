import 'package:app_koperasi/pages/home/admin/navigation_pages.dart';
import 'package:app_koperasi/pages/home/kasir/navigation_pages.dart';
import 'package:app_koperasi/pages/home/user/navigation_pages.dart';
import 'package:app_koperasi/pages/register_page.dart';
import 'package:app_koperasi/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final authService = AuthService();

  Future<void> _saveSession(int role, int id_users) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    await prefs.setInt('role', role);
    await prefs.setInt('id_users', id_users);
  }

  void _navigateBasedOnRole(int role) {
    print("Navigating to role $role");
    Widget nextPage;
    if (role == 1) {
      nextPage = AdminNavigationMenu();
    } else if (role == 2) {
      nextPage = NavigationMenuUser();
    } else {
      nextPage = KasirNavigationMenu();
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: "Username"),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: "Password"),
              obscureText: true,
            ),
            ElevatedButton(
              onPressed: () async {
                final res = await authService.login(
                  usernameController.text,
                  passwordController.text,
                );

                if (res.containsKey('id') && res.containsKey('role')) {
                  await _saveSession(res['role'], res['id']);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _navigateBasedOnRole(res['role']);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res['message'] ?? 'Login gagal')),
                  );
                }
              },
              child: Text("Login"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => RegisterPage()),
                );
              },
              child: Text("Belum punya akun? Daftar di sini"),
            ),
          ],
        ),
      ),
    );
  }
}
