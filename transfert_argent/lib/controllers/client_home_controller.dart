import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';
import 'package:transfert_argent/app/data/transaction_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import '../utils/validation_utils.dart';

class ClientHomeController extends GetxController {
  String formatTimestampToISO(Timestamp timestamp) {
    // Convertir Timestamp en DateTime
    DateTime dateTime = timestamp.toDate();

    // Convertir DateTime en une chaîne ISO 8601 avec UTC
    return dateTime.toUtc().toIso8601String();
  }

  RxDouble solde = 0.0.obs; // Solde dynamique
  RxString userId = ''.obs; // ID utilisateur connecté

  RxBool soldeVisible = true.obs; // Etat de visibilité du solde
  //
  RxString qrCode = 'assets/images/qr_code.png'.obs; // Image du QR code
  //
  RxBool isSoldeVisible = true.obs; // État pour afficher/masquer le solde

  // Champs pour le formulaire
  final numeroDestinataire = ''.obs;
  final montant = 0.0.obs;
  final errorMessage = ''.obs;
  final isButtonEnabled = false.obs;

  // Liste des contacts
  final contacts = <Contact>[].obs;
  @override
  void onInit() {
    super.onInit();
    fetchContacts();
    fetchUserSolde();
  }

  // Récupérer les contacts avec gestion des autorisations
  Future<void> fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      final allContacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
      contacts.assignAll(allContacts);
    } else {
      Get.snackbar(
        'Permissions manquantes',
        'Autorisez l\'accès aux contacts pour utiliser cette fonctionnalité.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void validateForm() {
    if (numeroDestinataire.value.isNotEmpty &&
        montant.value >= 1 &&
        montant.value <= solde.value && // Vérification du solde
        RegExp(r'^(77|78|76)\d{7}$').hasMatch(numeroDestinataire.value)) {
      isButtonEnabled.value = true;
      errorMessage.value = '';
    } else {
      isButtonEnabled.value = false;
      if (numeroDestinataire.value.isEmpty ||
          !RegExp(r'^(77|78|76)\d{7}$').hasMatch(numeroDestinataire.value)) {
        errorMessage.value = 'Numéro invalide. Format : 77XXXXXXX.';
      } else if (montant.value < 1) {
        errorMessage.value = 'Le montant doit être supérieur ou égal à 1.';
      } else if (montant.value > solde.value) {
        errorMessage.value = 'Le montant dépasse votre solde disponible.';
      }
    }
  }

  // Enregistrer une transaction
  Future<void> envoyerTransfert() async {
    try {
      // Déduction du montant du solde
      solde.value -= montant.value;

      await FirebaseFirestore.instance.collection('transactions').add({
        'client_id': FirebaseAuth.instance.currentUser!.uid,
        'type': 'envoi',
        'numero_destinataire': numeroDestinataire.value,
        'montant': montant.value,
        'etat': 'effectue',
        // 'client_id': 'user_id_placeholder', // Remplacer par l'ID réel du client
        'date': formatTimestampToISO(Timestamp.now()),
      });

      // Réinitialisation des champs après succès
      numeroDestinataire.value = '';
      montant.value = 0.0;

      // Validation dynamique pour désactiver le bouton
      validateForm();
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Impossible d\'enregistrer la transaction.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Toggle solde visibility
  void toggleSoldeVisibility() {
    isSoldeVisible.value = !isSoldeVisible.value;
  }

  // @override
  // void onInit() {
  //   super.onInit();
  //   fetchUserSolde();
  // }

  void fetchUserSolde() async {
    try {
      userId.value = FirebaseAuth.instance.currentUser!.uid;

      // Récupérer les données de l'utilisateur
      DocumentSnapshot userDoc =
          await fireStore.collection('users').doc(userId.value).get();

      if (userDoc.exists) {
        solde.value = double.parse(userDoc['solde'].toString());
      }
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de récupérer le solde utilisateur",
          backgroundColor: Colors.red);
    }
  }

  @override
  void onReady() {
    super.onReady();
    String clientId = FirebaseAuth.instance.currentUser!.uid;
    fetchClientTransactions(clientId);
  }

  FirebaseFirestore fireStore = FirebaseFirestore.instance;

  RxList<Transaction> transactions = <Transaction>[].obs;
  // RxList<Transaction> transactions = RxList<Transaction>();

  Future<void> fetchClientTransactions(String clientId) async {
    try {
      // QuerySnapshot snapshot = await fireStore
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('client_id', isEqualTo: clientId)
          // .orderBy('date', descending: true)
          .get();

      transactions.value = snapshot.docs
          .map((doc) =>
              Transaction.fromJson(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      Get.snackbar("Erreur", "Impossible de récupérer les transactions: $e");
      // ignore: avoid_print
      print(("Erreur", "Impossible de récupérer les transactions: $e"));
    }
  }

  //----------------- PARTIE TRANSACTION MULTIPLE:

  var selectedContacts = <Contact>[].obs; // Liste des contacts sélectionnés
  var montantMultiple = 0.0.obs; // Montant pour l'envoi multiple
  var isMultipleFormValid =
      false.obs; // État de validation du formulaire d'envoi multiple

  // Valider le formulaire d'envoi multiple
  void validateMultipleForm() {
    isMultipleFormValid.value = montantMultiple.value > 0 &&
        montantMultiple.value <= solde.value &&
        selectedContacts.isNotEmpty;
  }

  // Envoi multiple : créer une transaction pour chaque contact sélectionné
  Future<void> envoyerTransfertsMultiples() async {
    try {
      for (var contact in selectedContacts) {
        String numero = contact.phones.isNotEmpty
            ? contact.phones.first.number.replaceAll(' ', '')
            : '';

        await FirebaseFirestore.instance.collection('transactions').add({
          'type': 'envoi',
          'numero_destinataire': numero,
          'montant': montantMultiple.value,
          'etat': 'effectue',
          'client_id': FirebaseAuth.instance.currentUser!.uid,
          'date': formatTimestampToISO(Timestamp.now()),
        });
      }

      // Vider les sélections après succès
      selectedContacts.clear();
      montantMultiple.value = 0.0;

      Get.snackbar(
        'Succès',
        'Transferts multiples effectués avec succès !',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Erreur',
        'Échec de l\'envoi multiple : ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  //--------------------------------- DEBUT ANNULATION TRANSACTION:--------------------------

  Future<void> cancelTransaction(Transaction transaction) async {
    if (!TransactionDateUtils.isWithin30Minutes(transaction.date)) {
      Get.snackbar("Erreur", "La transaction ne peut plus être annulée.",
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      // Supprimer la transaction dans Firestore
      await FirebaseFirestore.instance
          .collection('transactions')
          .doc(transaction.id)
          .delete();

      // Supprimer localement la transaction
      transactions.remove(transaction);

      Get.snackbar(
        "Succès",
        "La transaction a été annulée avec succès.",
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (error) {
      Get.snackbar(
        "Erreur",
        "Impossible d'annuler la transaction. Veuillez réessayer.",
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void showCancelConfirmationDialog(Transaction transaction) {
    Get.defaultDialog(
      title: "Confirmer l'annulation",
      middleText: "Voulez-vous vraiment annuler cette transaction ?",
      textCancel: "Non",
      textConfirm: "Oui",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.find<ClientHomeController>().cancelTransaction(transaction);
        Get.back(); // Ferme la boîte de dialogue
      },
    );
  }
}

//--------------------------------- FIN ANNULATION TRANSACTION:--------------------------

//-------------------------------CLASSES ET TRAITEMENTS HORS CLIENT_HOME_CONTROLLER------------------------------------

extension on Contact {
  // ignore: unused_element
  replaceAll(String s, String t) {}
}

// ignore: use_key_in_widget_constructors
class TransfertPopup extends StatelessWidget {
  final ClientHomeController controller = Get.find<ClientHomeController>();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Transfert d\'argent'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Champ numéro destinataire
            Obx(() => TextField(
                  controller: TextEditingController(
                    text: controller.numeroDestinataire.value,
                  )..selection = TextSelection.fromPosition(
                      TextPosition(
                        offset: controller.numeroDestinataire.value.length,
                      ),
                    ),
                  onChanged: (value) {
                    controller.numeroDestinataire.value = value;
                    controller.validateForm();
                  },
                  decoration: InputDecoration(
                    labelText: 'Numéro destinataire',
                    errorText: controller.errorMessage.value.contains('Numéro')
                        ? controller.errorMessage.value
                        : null,
                  ),
                  keyboardType: TextInputType.phone,
                )),

            const SizedBox(height: 16.0),

            // Champ montant
            Obx(() => TextField(
                  onChanged: (value) {
                    controller.montant.value = double.tryParse(value) ?? 0.0;
                    controller.validateForm();
                  },
                  decoration: InputDecoration(
                    labelText: 'Montant',
                    errorText: controller.errorMessage.value.contains('montant')
                        ? controller.errorMessage.value
                        : null,
                  ),
                  keyboardType: TextInputType.number,
                )),

            const SizedBox(height: 16.0),

            // Liste des contacts
            const Text(
              'Contacts',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Obx(() => controller.contacts.isEmpty
                ? const Text('Aucun contact trouvé.')
                : SizedBox(
                    height: 200,
                    child: ListView.builder(
                      itemCount: controller.contacts.length,
                      itemBuilder: (context, index) {
                        final contact = controller.contacts[index];
                        final phone = contact.phones.isNotEmpty
                            ? contact.phones.first.number
                                .replaceAll(' ', '') // Supprime les espaces
                            : 'Numéro indisponible';
                        return ListTile(
                          title: Text(contact.displayName),
                          subtitle: Text(phone),
                          onTap: () {
                            // Mettre à jour le champ numéro
                            controller.numeroDestinataire.value = phone;
                            controller.validateForm();
                          },
                        );
                      },
                    ),
                  )),
          ],
        ),
      ),
      actions: [
        // Bouton Envoyer
        Obx(() => ElevatedButton(
              onPressed: controller.isButtonEnabled.value
                  ? () async {
                      await controller.envoyerTransfert();
                      Get.back(); // Fermer la popup après succès
                      Get.snackbar(
                        'Succès',
                        'Transaction effectuée avec succès !',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    }
                  : null,
              child: const Text('Envoyer'),
            )),
        // Bouton Annuler
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Annuler'),
        ),
      ],
    );
  }
}

class EnvoiMultiplePopup extends StatefulWidget {
  const EnvoiMultiplePopup({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _EnvoiMultiplePopupState createState() => _EnvoiMultiplePopupState();
}

class _EnvoiMultiplePopupState extends State<EnvoiMultiplePopup> {
  final ClientHomeController controller = Get.find<ClientHomeController>();
  List<Contact> contacts = [];
  List<String> selectedContacts = [];
  TextEditingController montantController = TextEditingController();
  bool showForm = false;

  @override
  void initState() {
    super.initState();
    fetchContacts();
  }

  Future<void> fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      List<Contact> phoneContacts = await FlutterContacts.getContacts(
        withProperties: true,
      );
      setState(() {
        contacts = phoneContacts;
      });
    }
  }

  void toggleContactSelection(String phoneNumber) {
    setState(() {
      if (selectedContacts.contains(phoneNumber)) {
        selectedContacts.remove(phoneNumber);
      } else {
        selectedContacts.add(phoneNumber);
      }
    });
  }

  void validateAndSend() {
    double? montant = double.tryParse(montantController.text);

    if (montant == null || montant <= 0) {
      Get.snackbar('Erreur', 'Le montant doit être supérieur à 0');
      return;
    }

    if (montant > controller.solde.value) {
      Get.snackbar('Erreur', 'Le montant dépasse votre solde disponible');
      return;
    }

    // Convertir les numéros de téléphone sélectionnés en objets Contact
    List<Contact> selectedContactObjects = contacts.where((contact) {
      final phoneNumber = contact.phones.isNotEmpty
          ? contact.phones.first.number.replaceAll(' ', '')
          : '';
      return selectedContacts.contains(phoneNumber);
    }).toList();

    // Mettre à jour les valeurs dans le contrôleur
    controller.montantMultiple.value = montant;
    controller.selectedContacts.value = selectedContactObjects;

    // Appeler la fonction d'envoi multiple
    controller.envoyerTransfertsMultiples();

    // Fermer le popup et afficher un message de succès
    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Envoi multiple'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!showForm)
            Expanded(
              child: contacts.isEmpty
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: contacts.length,
                      itemBuilder: (context, index) {
                        final contact = contacts[index];
                        final phoneNumber = contact.phones.isNotEmpty
                            ? contact.phones.first.number
                            : 'Inconnu';
                        return ListTile(
                          title: Text(contact.displayName),
                          subtitle: Text(phoneNumber),
                          trailing: Checkbox(
                            value: selectedContacts.contains(phoneNumber),
                            onChanged: (isSelected) {
                              toggleContactSelection(phoneNumber);
                            },
                          ),
                        );
                      },
                    ),
            ),
          if (selectedContacts.isNotEmpty && !showForm)
            ElevatedButton(
              onPressed: () {
                setState(() {
                  showForm = true;
                });
              },
              child: Text('Terminer sélection'),
            ),
          if (showForm)
            Column(
              children: [
                TextField(
                  controller: montantController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Montant',
                    hintText: 'Entrez un montant',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: validateAndSend,
                  child: Text('Envoyer'),
                ),
              ],
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Get.back();
          },
          child: Text('Annuler'),
        ),
      ],
    );
  }
}
