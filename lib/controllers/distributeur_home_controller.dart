import 'package:get/get.dart';
import '../utils/firebase_service.dart';
import 'auth_controller.dart';

class DistributeurHomeController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final isLoading = false.obs;

  RxDouble solde = 0.0.obs;
  RxBool soldeVisible = true.obs;
  RxString qrCode = 'assets/images/qr_code.png'.obs;
  RxList<Transaction> transactions = <Transaction>[].obs;

  final AuthController _authController = AuthController.instance;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  void toggleSoldeVisibility() {
    soldeVisible.value = !soldeVisible.value;
  }

  Future<void> _loadData() async {
    try {
      final userId = _authController.user.value?.uid;

      if (userId != null) {
        solde.value = await _firebaseService.getDistributeurSolde(userId);
        final transactionData =
            await _firebaseService.getDistributeurTransactions(userId);
        transactions.assignAll(transactionData.map((data) {
          return Transaction(
            type: data['type'],
            montant: data['montant']?.toDouble() ?? 0.0,
            date: data['date'],
          );
        }).toList());
      }
    } catch (e) {
      Get.snackbar('Erreur', e.toString());
    }
  }
}

class Transaction {
  final String type;
  final double montant;
  final String date;

  Transaction({required this.type, required this.montant, required this.date});
}


// class DistributeurHomeController extends GetxController {
//   RxDouble solde = 10000.0.obs;
//   RxBool soldeVisible = true.obs;
//   RxString qrCode = 'assets/images/qr_code.png'.obs;
//   RxList<Transaction> transactions = <Transaction>[
//     Transaction(type: 'Dépôt', montant: 5000.0, date: '2024-11-17 14:30'),
//     Transaction(type: 'Retrait', montant: 2000.0, date: '2024-11-16 10:00'),
//     Transaction(type: 'Deplafonner', montant: 1000.0, date: '2024-11-15 18:20'),
//   ].obs;

//   void toggleSoldeVisibility() {
//     soldeVisible.value = !soldeVisible.value;
//   }
// }

// class Transaction {
//   final String type;
//   final double montant;
//   final String date;

//   Transaction({required this.type, required this.montant, required this.date});
// }
