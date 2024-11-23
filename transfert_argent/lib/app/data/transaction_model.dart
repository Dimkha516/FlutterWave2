class Transaction {
  final String id;
  final String type;
  final double montant;
  late final String etat;
  final String clientId;
  final String? numeroDestinataire; // Obligatoire pour type "envoi"
  final String? distributeurId; // Obligatoire pour type "retrait" ou "dépôt"
  final DateTime date;

  Transaction({
    required this.id,
    required this.type,
    required this.montant,
    required this.etat,
    required this.clientId,
    this.numeroDestinataire,
    this.distributeurId,
    required this.date,
  });

  factory Transaction.fromJson(String id, Map<String, dynamic> json) {
    return Transaction(
      id: id,
      type: json['type'],
      montant: json['montant'].toDouble(),
      etat: json['etat'],
      clientId: json['client_id'],
      numeroDestinataire: json['numero_destinataire'],
      distributeurId: json['distributeur_id'],
      date: DateTime.parse(json['date']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'montant': montant,
      'etat': etat,
      'client_id': clientId,
      'numero_destinataire': numeroDestinataire,
      'distributeur_id': distributeurId,
      'date': date.toIso8601String(),
    };
  }

  static Future<void> fromMap(Map<String, dynamic> data) async {}
}
