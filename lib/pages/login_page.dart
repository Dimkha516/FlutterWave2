import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final authController = Get.put(AuthController());

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: "Mot de passe"),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _handleEmailPasswordLogin(),
              child: const Text("Se connecter"),
            ),
            const SizedBox(height: 20),
            const Text(
              "OU",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _handleGoogleLogin(),
              icon: const Icon(
                  Icons.g_mobiledata), // Ou utilisez une image Google
              label: const Text("Se connecter avec Google"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
              ),
            ),
            TextButton(
              onPressed: () {
                Get.toNamed('/register');
              },
              child: const Text("Vous n'avez pas de compte? S'inscrire"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleEmailPasswordLogin() async {
    Get.dialog(
      const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text(
              "Connexion en cours...",
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );

    try {
      await authController.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );
    } finally {
      Get.back(); // Ferme le dialogue de chargement
    }
  }

  Future<void> _handleGoogleLogin() async {
    try {
      Get.dialog(
        const Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text(
                "Connexion avec Google en cours...",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
        barrierDismissible: false,
      );

      await authController.signInWithGoogle();
    } catch (e) {
      print("Erreur dans _handleGoogleLogin : $e");
      Get.back(); // Ferme le dialogue de chargement
      Get.snackbar(
        "Erreur",
        "Échec de la connexion Google : ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(title: const Text("Connexion")),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         children: [
  //           TextField(
  //             controller: emailController,
  //             decoration: const InputDecoration(labelText: "Email"),
  //           ),
  //           TextField(
  //             controller: passwordController,
  //             decoration: const InputDecoration(labelText: "Mot de passe"),
  //             obscureText: true,
  //           ),
  //           const SizedBox(height: 20),
  //           ElevatedButton(
  //             onPressed: () async {
  //               // Affichage du loader
  //               Get.dialog(
  //                 const Center(
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       CircularProgressIndicator(),
  //                       SizedBox(height: 10),
  //                       Text(
  //                         "Connexion en cours...",
  //                         style: TextStyle(fontSize: 16),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 barrierDismissible:
  //                     false, // Empêche la fermeture de la boîte de dialogue
  //               );

  //               // Tentative de connexion
  //               try {
  //                 await authController.login(
  //                   emailController.text.trim(),
  //                   passwordController.text.trim(),
  //                 );
  //                 // Fermeture du loader après succès
  //                 Get.back();
  //               } catch (e) {
  //                 // Fermeture du loader en cas d'échec
  //                 Get.back();
  //                 // Affichage d'une alerte en cas d'erreur
  //                 Get.snackbar("Erreur", e.toString(),
  //                     snackPosition: SnackPosition.BOTTOM);
  //               }
  //             },
  //             child: const Text("Se connecter"),
  //           ),
  //           // Lien vers la page d'inscription
  //           TextButton(
  //             onPressed: () {
  //               Get.toNamed('/register');
  //             },
  //             child: const Text("Vous n'avez pas de compte? S'inscrire"),
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
