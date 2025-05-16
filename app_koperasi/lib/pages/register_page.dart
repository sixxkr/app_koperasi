import 'package:app_koperasi/pages/login_page.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  int? selectedRole;

  final authService = AuthService();

  final List<Map<String, dynamic>> roles = [
    {'value': 1, 'label': 'Admin'},
    {'value': 2, 'label': 'User'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: usernameController,
              decoration: InputDecoration(labelText: 'Username'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Password'),
            ),
            ElevatedButton(
              onPressed: () async {
                final message = await authService.register(
                  nameController.text,
                  usernameController.text,
                  passwordController.text,
                  selectedRole ?? 2,
                );
                ScaffoldMessenger.of(context)
                    .showSnackBar(SnackBar(content: Text(message)));

                if (message == "Register berhasil") {
                  Navigator.pushReplacementNamed(context, '/');
                }
              },
              child: Text("Register"),
            ),
            TextButton(
              onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => LoginPage()),
              ),
              child: Text("Sudah punya akun? Login"),
            )
          ],
        ),
      ),
    );
  }
}
