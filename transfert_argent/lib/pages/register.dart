import 'package:flutter/material.dart';
import 'package:transfert_argent/controllers/auth_controller.dart';

class RegisterPage extends StatelessWidget {
  final AuthController authController = AuthController.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController profileController = TextEditingController();

  RegisterPage({super.key}); // Profil (client, distributeur)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: phoneController,
              decoration: InputDecoration(labelText: 'Phone Number'),
            ),
            TextField(
              controller: profileController,
              decoration: InputDecoration(
                  labelText: 'Profile (client or distributeur)'),
            ),
            ElevatedButton(
              onPressed: () {
                authController.register(
                  emailController.text,
                  passwordController.text,
                  nameController.text,
                  phoneController.text,
                  profileController.text,
                );
              },
              child: Text('Register'),
            ),
          ],
        ),
      ),
    );
  }
}
