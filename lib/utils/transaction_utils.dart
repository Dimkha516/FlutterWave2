import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
// ignore: unused_import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:transfert_argent/app/data/transaction_model.dart';

class TransactionUtils {
  static final _firestore = FirebaseFirestore.instance;

  /// Ajouter une transaction
  static Future<void> addTransaction({
    required String type,
    required String numeroDestinataire,
    required double montant,
    required String clientId,
  }) async {
    await _firestore.collection('transactions').add({
      'client_id': clientId,
      'type': type,
      'numero_destinataire': numeroDestinataire,
      'montant': montant,
      'etat': 'effectue',
      'date': Timestamp.now().toDate().toIso8601String(),
    });
  }

  /// Récupérer les transactions d'un client
  static Future<List<Transaction>> fetchTransactions(String clientId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('transactions')
        .where('client_id', isEqualTo: clientId)
        .get();

    return snapshot.docs
        .map((doc) =>
            Transaction.fromJson(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }
}
