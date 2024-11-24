import 'package:cloud_firestore/cloud_firestore.dart';

class Planification {
  final String id;
  final String clientId;
  final String destinataire;
  final double montant;
  final String frequence;
  final String status;
  final DateTime prochaineEcheance;

  Planification({
    required this.id,
    required this.clientId,
    required this.destinataire,
    required this.montant,
    required this.frequence,
    required this.status,
    required this.prochaineEcheance,
  });

  factory Planification.fromFirestore(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Planification(
      id: doc.id,
      clientId: data['client_id'] as String? ?? '',
      destinataire: data['destinataire'] as String? ?? '',
      montant: (data['montant'] as num?)?.toDouble() ?? 0.0,
      frequence: data['frequence'] as String? ?? '',
      status: data['status'] as String? ?? '',
      prochaineEcheance: data['prochaine_echeance'] != null
          ? (data['prochaine_echeance'] as Timestamp).toDate()
          : DateTime.now(),
      // prochaineEcheance: (data['prochaine_echeance'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // prochaineEcheance: (data['prochaine_echeance'] as Timestamp).toDate(),
    );
  }

  factory Planification.fromMap(Map<String, dynamic> data) {
    return Planification(
      id: data['id'],
      clientId: data['client_id'],
      destinataire: data['destinataire'],
      montant: data['montant'],
      frequence: data['frequence'],
      status: data['status'],
      prochaineEcheance: data['prochaine_echeance'],
    );
  }

  static fromJson(String id, Map<String, dynamic> data) {}
}

// php artisan tinker
// dispatch(new \App\Jobs\ExecutePlanifications());
