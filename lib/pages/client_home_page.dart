import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transfert_argent/controllers/client_home_controller.dart';

// ignore: use_key_in_widget_constructors
class ClientHomePage extends StatelessWidget {
  final ClientHomeController controller = Get.put(ClientHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Client'),
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              // Afficher le sidebar
              Get.toNamed('/sidebar');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Section solde et QR Code (fixe)
          Obx(() => Container(
                padding: const EdgeInsets.all(16.0),
                color: Colors.blueGrey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              controller.isSoldeVisible.value
                                  ? 'Solde: ${controller.solde.value.toStringAsFixed(2)} Fr'
                                  : 'Solde: ****',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                controller.isSoldeVisible.value
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.blue,
                              ),
                              onPressed: controller.toggleSoldeVisibility,
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 16.0),
                    Center(
                        child: Obx(
                      () => Image.asset(
                        controller.qrCode.value,
                        width: 150, // Ajustez la taille si nécessaire
                        height: 150,
                        fit: BoxFit.cover,
                      ),
                    )),
                  ],
                ),
              )),

          // Boutons Transfert, Paiement, Crédit
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Get.dialog(TransfertPopup());

                    // Fonctionnalité de Transfert
                  },
                  child: const Text('Transfert'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Fonctionnalité de Paiement
                  },
                  child: const Text('Paiement'),
                ),
                ElevatedButton(
                  onPressed: () {
                    // Fonctionnalité de Crédit
                  },
                  child: const Text('Crédit'),
                ),
              ],
            ),
          ),

          // // Historique des transactions
          Expanded(
            child: Obx(() => controller.transactions.isEmpty
                ? const Center(child: Text('Aucune transaction trouvée.'))
                : ListView.builder(
                    itemCount: controller.transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = controller.transactions[index];
                      final now = DateTime.now();
                      final canCancel =
                          now.difference(transaction.date).inMinutes < 30;

                      return ListTile(
                        leading: Text(transaction.type),
                        title: Text('${transaction.montant} FCFA'),
                        subtitle: Text(transaction.date.toLocal().toString()),
                        trailing: canCancel
                            ? ElevatedButton(
                                onPressed: () {
                                  controller.showCancelConfirmationDialog(
                                      transaction);
                                },
                                child: Text("Annuler"),
                              )
                            : Text(transaction.etat,
                                style: TextStyle(
                                  color: transaction.etat == 'Annulée'
                                      ? Colors.red
                                      : Colors.grey,
                                )),
                      );
                    },
                  )),
          )
          // Expanded(
          //   child: Obx(() => controller.transactions.isEmpty
          //       ? const Center(child: Text('Aucune transaction trouvée.'))
          //       : ListView.builder(
          //           itemCount: controller.transactions.length,
          //           itemBuilder: (context, index) {
          //             final transaction = controller.transactions[index];
          //             return ListTile(
          //               leading: Text(transaction.type),
          //               title: Text('${transaction.montant} FCFA'),
          //               subtitle: Text(transaction.date.toLocal().toString()),
          //               trailing: Text(transaction.etat),
          //             );
          //           },
          //         )),
          // ),
        ],
      ),
    );
  }
}
