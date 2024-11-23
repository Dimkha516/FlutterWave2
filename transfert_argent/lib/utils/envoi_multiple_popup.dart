// lib/app/widgets/envoi_multiple_popup.dart
import 'package:flutter/material.dart';

class EnvoiMultiplePopup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Envoi Multiple'),
      content: Text('Vous pouvez envoyer à plusieurs destinataires ici.'),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fermer la popup
          },
          child: Text('Annuler'),
        ),
        TextButton(
          onPressed: () {
            // Logique d'envoi multiple
            Navigator.of(context).pop(); // Fermer la popup après l'action
          },
          child: Text('Envoyer'),
        ),
      ],
    );
  }
}
