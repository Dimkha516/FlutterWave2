import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transfert_argent/app/data/planification_model.dart';

class PlanificationController extends GetxController {
  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchPlanifications(clientId);
  // }

  @override
  void onReady() {
    super.onReady();
    String clientId = FirebaseAuth.instance.currentUser!.uid;
    fetchPlanifications(clientId);
  }

  //------------------RÉCUPÉRER LES TRANSACTIONS DE L'UTILISATEUR CONNECTÉ---------------
  FirebaseFirestore fireStore = FirebaseFirestore.instance;
  RxList<Planification> planifications = <Planification>[].obs;

  Future<void> fetchPlanifications(String clientId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('planifications')
          .where('client_id', isEqualTo: clientId)
          .get();

      planifications.value = snapshot.docs
          .map<Planification>((doc) => Planification.fromFirestore(doc))
          .toList();
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de récupérer les planifications: $e");
      // ignore: avoid_print
      print("Erreur: Impossible de récupérer les planifications: $e");
    }
  }

  // Future<void> fetchPlanifications(String clientId) async {
  //   try {
  //     // QuerySnapshot snapshot = await fireStore
  //     QuerySnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('planifications')
  //         .where('client_id', isEqualTo: clientId)
  //         // .orderBy('date', descending: true)
  //         .get();

  //     planifications.value = snapshot.docs
  //         .map<Planification>((doc) => Planification.fromJson(
  //             doc.id, doc.data() as Map<String, dynamic>))
  //         .toList();
  //   } catch (e) {
  //     Get.snackbar("Erreur", "Impossible de récupérer les planificaions: $e");
  //     // ignore: avoid_print
  //     print(("Erreur", "Impossible de récupérer les planifications: $e"));
  //   }
  // }

  //------------------AJOUTER UNE PLANIFICATION DE TRANSFERT---------------
  Future<void> addPlanification(
      String numeroDestinataire, double montant, String frequence) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!
          .uid; // Remplacez par l'ID réel de l'utilisateur connecté
      final now = DateTime.now();

      // Calculer la prochaine échéance
      DateTime prochaineEcheance;
      if (frequence == "journalier") {
        prochaineEcheance = now.add(Duration(days: 1));
      } else if (frequence == "hebdomadaire") {
        prochaineEcheance = now.add(Duration(days: 7));
      } else {
        prochaineEcheance = now.add(Duration(days: 30));
      }

      final docRef =
          FirebaseFirestore.instance.collection('planifications').doc();
      final planification = {
        "id": docRef.id,
        "client_id": userId,
        "destinataire": numeroDestinataire,
        "montant": montant,
        "frequence": frequence,
        "status": 'En attente',
        "prochaine_echeance": prochaineEcheance,
      };

      await docRef.set(planification);

      planifications.add(Planification.fromMap(planification));

      Get.back(); // Retour à la page planifications
      Get.snackbar("Succès", "Planification ajoutée avec succès !");
    } catch (error) {
      Get.snackbar("Erreur", "Impossible d'ajouter la planification.");
    }
  }

  //------------------SUPPRESSION TRANSACTION PLANIFIÉE---------------
  Future<void> showDeleteConfirmation(String planificationId) async {
    final confirmation = await Get.dialog<bool>(
      AlertDialog(
        title: Text("Confirmation"),
        content: Text("Voulez-vous vraiment annuler cette planification ?"),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text("Non"),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text("Oui"),
          ),
        ],
      ),
    );

    if (confirmation == true) {
      await deletePlanification(planificationId);
    }
  }

  // Supprimer une planification
  Future<void> deletePlanification(String planificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('planifications')
          .doc(planificationId)
          .delete();

      // Mettre à jour la liste localement
      planifications.removeWhere((p) => p.id == planificationId);

      Get.snackbar("Succès", "Planification annulée avec succès.");
    } catch (error) {
      Get.snackbar("Erreur", "Impossible d'annuler la planification.");
    }
  }
}
