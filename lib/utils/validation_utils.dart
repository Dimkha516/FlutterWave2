import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionDateUtils {
  static String formatTimestampToISO(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return dateTime.toUtc().toIso8601String();
  }

  static bool isWithin30Minutes(DateTime transactionDate) {
    DateTime now = DateTime.now().toUtc();
    Duration difference = now.difference(transactionDate);
    return difference.inMinutes.abs() <= 30;
  }
}
