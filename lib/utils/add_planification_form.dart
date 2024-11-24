import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:transfert_argent/controllers/planification_controller.dart';

class AddPlanificationForm extends StatelessWidget {
  final controller = Get.find<PlanificationController>();

  final _formKey = GlobalKey<FormState>();
  final numeroController = TextEditingController();
  final montantController = TextEditingController();
  final frequenceController = TextEditingController();

  AddPlanificationForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Nouvelle Planification")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: numeroController,
                decoration: InputDecoration(labelText: "Numéro Destinataire"),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value!.isEmpty ? "Champ obligatoire" : null,
              ),
              TextFormField(
                controller: montantController,
                decoration: InputDecoration(labelText: "Montant"),
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? "Champ obligatoire" : null,
              ),
              DropdownButtonFormField<String>(
                value: "journalier",
                items: ["journalier", "hebdomadaire", "mensuel"]
                    .map((freq) => DropdownMenuItem(
                          value: freq,
                          child: Text(freq.capitalizeFirst!),
                        ))
                    .toList(),
                onChanged: (value) {
                  frequenceController.text = value!;
                },
                decoration: InputDecoration(labelText: "Fréquence"),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    controller.addPlanification(
                      numeroController.text,
                      double.parse(montantController.text),
                      frequenceController.text,
                    );
                  }
                },
                child: Text("Valider"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
