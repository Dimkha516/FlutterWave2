import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<double> getDistributeurSolde(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();
      return (userDoc.data() as Map<String, dynamic>)['solde']?.toDouble() ??
          0.0;
    } catch (e) {
      throw Exception("Erreur lors de la récupération du solde: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getDistributeurTransactions(
      String userId) async {
    try {
      QuerySnapshot transactionSnapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('distributeur_id', isEqualTo: userId)
          // .orderBy('date', descending: true)
          .get();

      return transactionSnapshot.docs.map((doc) {
        return doc.data() as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      throw Exception("Erreur lors de la récupération des transactions: $e");
    }
  }
}
