import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:transfert_argent/pages/sidebar_page.dart';
import 'package:transfert_argent/pages/transaction_page.dart';
import 'pages/login_page.dart';
import 'pages/client_home_page.dart';
import 'pages/distributeur_home_page.dart';
import 'pages/register.dart';

void main() async {
  WidgetsFlutterBinding
      .ensureInitialized(); // Assure-toi que le binding est initialisé
  await Firebase.initializeApp(); // Initialisation de Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => LoginPage()),
        GetPage(name: '/register', page: () => RegisterPage()),
        GetPage(name: '/clientHome', page: () => ClientHomePage()),
        GetPage(name: '/distributeurHome', page: () => DistributeurHomePage()),
        GetPage(name: '/sidebar', page: () => SidebarPage()),
        GetPage(name: '/depot', page: () => TransactionPage(type: 'Dépôt')),
        GetPage(name: '/retrait', page: () => TransactionPage(type: 'Retrait')),
      ],
    );
  }
}
