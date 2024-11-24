import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transfert_argent/controllers/client_home_controller.dart';
import 'package:transfert_argent/pages/planifications_page.dart';

class SidebarPage extends StatelessWidget {
  const SidebarPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialiser le contrôleur
    // ignore: unused_local_variable
    final ClientHomeController controller = Get.find<ClientHomeController>();

    return Scaffold(
      appBar: AppBar(title: Text('Menu')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Planifier transaction'),
            onTap: () {
              // Rediriger vers la page de planification
              Get.to(() => PlanificationsPage());
            },
          ),
          ListTile(
            title: Text('Envoi multiple'),
            onTap: () {
              // Afficher le popup pour l'envoi multiple
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return EnvoiMultiplePopup(); // Affichez le composant créé
                },
              );
            },
          ),
          ListTile(
            title: Text('Déconnexion'),
            onTap: () {
              // Déconnecter l'utilisateur
              FirebaseAuth.instance.signOut();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
    );
  }
}
