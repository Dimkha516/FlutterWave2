import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transfert_argent/controllers/planification_controller.dart';
import 'package:transfert_argent/utils/add_planification_form.dart';

// ignore: use_key_in_widget_constructors
class PlanificationsPage extends StatelessWidget {
  final controller = Get.put(PlanificationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Planifications")),
      body: Obx(() => controller.planifications.isEmpty
          ? Center(child: Text("Aucune planification trouvée."))
          : ListView.builder(
              itemCount: controller.planifications.length,
              itemBuilder: (context, index) {
                final planification = controller.planifications[index];
                return ListTile(
                  leading: Icon(Icons.schedule),
                  title: Text("Destinataire: ${planification.destinataire}"),
                  subtitle: Text(
                    "Montant: ${planification.montant} FCFA\n"
                    "Fréquence: ${planification.frequence}\n"
                    "Status: ${planification.status}\n"
                    "Prochaine échéance: ${planification.prochaineEcheance.toLocal()}",
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () =>
                        controller.showDeleteConfirmation(planification.id),
                  ),
                );
              },
            )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => AddPlanificationForm());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
