import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:get/get.dart';

class ContactUtils {
  /// Récupérer les contacts avec autorisations
  static Future<List<Contact>> fetchContacts() async {
    if (await FlutterContacts.requestPermission()) {
      return await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );
    } else {
      Get.snackbar(
        'Permissions manquantes',
        'Autorisez l\'accès aux contacts pour utiliser cette fonctionnalité.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return [];
    }
  }
}
