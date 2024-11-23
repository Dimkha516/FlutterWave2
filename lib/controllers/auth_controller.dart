// ignore_for_file: avoid_print

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  static AuthController instance = Get.find();
  FirebaseAuth auth = FirebaseAuth.instance;
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Rxn<User> user = Rxn<User>();

  @override
  void onInit() {
    super.onInit();
    user.bindStream(auth.authStateChanges());
  }

  // Méthode existante de login avec email/password
  Future<void> login(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      await _handlePostSignIn(userCredential.user!);
    } catch (e) {
      Get.snackbar("Erreur", e.toString(), backgroundColor: Colors.red);
    }
  }

  // Nouvelle méthode pour la connexion Google
  Future<void> signInWithGoogle() async {
    try {
      print("Début de la connexion Google");

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("L'utilisateur a annulé la connexion Google");
        throw "Connexion Google annulée";
      }

      print("Utilisateur Google sélectionné : ${googleUser.email}");

      print("Obtention des informations d'authentification Google");
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      print("Création des credentials Firebase");
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      print("Connexion à Firebase");
      UserCredential userCredential =
          await auth.signInWithCredential(credential);

      print("Utilisateur Firebase connecté : ${userCredential.user?.email}");

      // Vérifier si c'est un nouvel utilisateur
      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        print("Création d'un nouveau profil utilisateur dans Firestore");
        await fireStore.collection('users').doc(userCredential.user!.uid).set({
          'email': userCredential.user!.email,
          'profile': 'client',
          'createdAt': DateTime.now(),
          'provider': 'google'
        });
      }

      print("Traitement post-connexion");
      await _handlePostSignIn(userCredential.user!);

      print("Connexion Google terminée avec succès");
    } catch (e) {
      print("Erreur lors de la connexion Google : $e");
      throw e; // Rethrow pour que l'erreur soit capturée dans la page de login
    }
  }

  // Méthode utilitaire pour gérer la post-connexion
  Future<void> _handlePostSignIn(User user) async {
    try {
      print("Récupération du document utilisateur");

      DocumentSnapshot userDoc =
          await fireStore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        Get.snackbar("Erreur", "L'utilisateur n'existe pas dans Firestore.",
            backgroundColor: Colors.red);
        print("Document utilisateur non trouvé");
        return;
      }

      String? profile = userDoc['profile'];
      if (profile == null) {
        Get.snackbar("Erreur", "Le profil est manquant dans le document.",
            backgroundColor: Colors.red);
        print("Profil manquant");
        return;
      }
      print("Redirection vers la page du profil : $profile");

      if (profile == 'client') {
        Get.offAllNamed('/clientHome');
      } else if (profile == 'distributeur') {
        Get.offAllNamed('/distributeurHome');
      } else {
        Get.snackbar("Erreur", "Profil inconnu.", backgroundColor: Colors.red);
      }
    } catch (e) {
      Get.snackbar("Erreur", e.toString(), backgroundColor: Colors.red);
    }
  }

  // Méthode de déconnexion
  Future<void> signOut() async {
    await auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<void> register(String email, String password, String name,
      String phone, String profile) async {
    try {
      // Vérification des champs
      if (email.isEmpty ||
          password.isEmpty ||
          name.isEmpty ||
          phone.isEmpty ||
          profile.isEmpty) {
        Get.snackbar("Erreur", "Tous les champs doivent être remplis",
            backgroundColor: Colors.red);
        return;
      }

      // Créer l'utilisateur avec l'email et le mot de passe
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Ajouter l'utilisateur dans Firestore
      await fireStore.collection('users').doc(userCredential.user!.uid).set({
        'email': email,
        'name': name,
        'phone': phone,
        'profile': profile, // 'client' ou 'distributeur'
        'qr_code': 'qr.png', // Valeur par défaut
        'solde': 5000, // Solde initial
      });

      // Redirection vers la page de connexion
      Get.snackbar("Succès", "Inscription réussie, veuillez vous connecter",
          backgroundColor: Colors.green);
      Get.offAllNamed('/login');
    } catch (e) {
      Get.snackbar("Erreur", e.toString(), backgroundColor: Colors.red);
    }
  }
}
