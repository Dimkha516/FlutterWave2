import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transfert_argent/controllers/distributeur_home_controller.dart';

// ignore: use_key_in_widget_constructors
class DistributeurHomePage extends StatelessWidget {
  final DistributeurHomeController controller =
      Get.put(DistributeurHomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Accueil Distributeur'),
        actions: [
          IconButton(
            icon: Icon(Icons.menu),
            onPressed: () {
              // Get.toNamed('/sidebar');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Section solde et QR Code (fixe)
          Obx(() => Container(
                padding: EdgeInsets.all(16.0),
                color: Colors.blueGrey[50],
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Affichage du solde
                        Text(
                            'Solde: ${controller.solde.value.toStringAsFixed(2)} Fr'),
                        IconButton(
                          icon: Icon(controller.soldeVisible.value
                              ? Icons.visibility_off
                              : Icons.visibility),
                          onPressed: controller.toggleSoldeVisibility,
                        ),
                      ],
                    ),
                    if (controller.soldeVisible.value) Text('Solde visible'),
                    Image.asset(controller.qrCode.value,
                        width: 100, height: 100),
                  ],
                ),
              )),

          // Section boutons spécifiques au distributeur
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Get.toNamed('/depot'),
                  child: Text('Dépôt'),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/retrait'),
                  child: Text('Retrait'),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed('/deplafonner'),
                  child: Text('Deplafonner'),
                ),
              ],
            ),
          ),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (controller.transactions.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.history,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Aucune transaction trouvée',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                itemCount: controller.transactions.length,
                itemBuilder: (context, index) {
                  final transaction = controller.transactions[index];
                  return ListTile(
                    leading: Text(transaction.type),
                    title: Text('${transaction.montant} FCFA'),
                    subtitle: Text(transaction.date),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
