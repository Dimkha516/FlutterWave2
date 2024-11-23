import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:get/get.dart';

class ScannerPage extends StatelessWidget {
  const ScannerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Scanner le QR Code'),
      ),
      body: MobileScanner(
        onDetect: (BarcodeCapture barcodeCapture) {
          final List<Barcode> barcodes = barcodeCapture.barcodes;
          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
            final String code = barcodes.first.rawValue!;
            Get.back(result: code); // Retourner la valeur scannée
          } else {
            Get.snackbar("Erreur", "Code QR invalide");
          }
        },
      ),
    );
  }
}
// 3.5.5 