// ===== scan_qr.dart =====================================
// QR code scanner screen.

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

  @override
  Widget buildqr(BuildContext context, Function(String) func) {
    MobileScannerController cameraController = MobileScannerController();
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 20,
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            MobileScanner(
              allowDuplicates: false,
              controller: cameraController,
              onDetect: (barcode, args) {
                if (barcode.rawValue == null) {
                  debugPrint('Failed to scan Barcode');
                  Navigator.of(context).pop();
                } else {
                  final String code = barcode.rawValue!;
                  func(code);
                  Navigator.of(context).pop();
                }
              }
            ),
            Align(
              alignment: Alignment.bottomCenter,
              heightFactor: 3,
              child: Text(
                "Scan Device QR",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.grey.withAlpha(245),
              
                ),
              ),
            ),
          ],
        ),
      );
  }
