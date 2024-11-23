import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transfert_argent/pages/scanner_page.dart';

class TransactionPage extends StatelessWidget {
  final String type; // "Dépôt" ou "Retrait"
  TransactionPage({super.key, required this.type});

  final RxString numeroTelephone = '771234455'.obs;
  final RxDouble montant = 0.0.obs;
  final TextEditingController montantController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$type de fonds'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Scanner le QR Code
            ElevatedButton(
              onPressed: () async {
                final result = await Get.to(() => ScannerPage());
                if (result != null) {
                  Get.snackbar(
                    "QR Code scanné",
                    "Code : $result",
                    snackPosition: SnackPosition.BOTTOM,
                  );
                }
              },
              child: Text('Scanner QR Code'),
            ),
            SizedBox(height: 20),

            // Champ : Numéro de téléphone
            TextField(
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Numéro de téléphone',
                border: OutlineInputBorder(),
                hintText: '771234455',
              ),
            ),
            SizedBox(height: 10),

            // Champ : Montant
            TextField(
              controller: montantController,
              keyboardType: TextInputType.number,
              onChanged: (value) =>
                  montant.value = double.tryParse(value) ?? 0.0,
              decoration: InputDecoration(
                labelText: 'Montant',
                border: OutlineInputBorder(),
                hintText: 'Entrez le montant',
              ),
            ),
            SizedBox(height: 20),

            // Bouton de validation
            Obx(() => ElevatedButton(
                  onPressed: montant.value > 0
                      ? () {
                          // Simuler la validation
                          Get.back(); // Retour à la page principale
                          Get.snackbar(
                            "Succès",
                            "Transaction effectuée avec succès",
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        }
                      : null, // Désactiver si montant <= 0
                  child: Text('Valider $type'),
                )),
          ],
        ),
      ),
    );
  }
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: Text('$type de fonds'),
  //     ),
  //     body: Padding(
  //       padding: const EdgeInsets.all(16.0),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Scanner le QR Code
  //           ElevatedButton(
  //             onPressed: () async {
  //               final result = await Get.to(() => ScannerPage());
  //               if (result != null) {
  //                 Get.snackbar("QR Code scanné", "Code : $result",
  //                     snackPosition: SnackPosition.BOTTOM);
  //               }
  //             },
  //             child: Text('Scanner QR Code'),
  //           ),
  //           SizedBox(height: 20),

  //           // Formulaire
  //           TextField(
  //             readOnly: true,
  //             decoration: InputDecoration(
  //               labelText: 'Numéro de téléphone',
  //               border: OutlineInputBorder(),
  //               hintText: '771234455',
  //             ),
  //           ),
  //           SizedBox(height: 10),
  //           Obx(() => TextField(
  //                 keyboardType: TextInputType.number,
  //                 onChanged: (value) =>
  //                     montant.value = double.tryParse(value) ?? 0.0,
  //                 decoration: InputDecoration(
  //                   labelText: 'Montant',
  //                   border: OutlineInputBorder(),
  //                   hintText: 'Entrez le montant',
  //                 ),
  //               )),
  //           SizedBox(height: 20),

  //           // Bouton de validation
  //           Obx(() => ElevatedButton(
  //                 onPressed: montant.value > 0
  //                     ? () {
  //                         // Simuler la validation
  //                         Get.back(); // Retour à la page principale
  //                         Get.snackbar(
  //                           "Succès",
  //                           "Transaction effectuée avec succès",
  //                           snackPosition: SnackPosition.BOTTOM,
  //                           backgroundColor: Colors.green,
  //                           colorText: Colors.white,
  //                         );
  //                       }
  //                     : null,
  //                 child: Text('Valider $type'),
  //               )),
  //         ],
  //       ),
  //     ),
  //   );
  // }
}
