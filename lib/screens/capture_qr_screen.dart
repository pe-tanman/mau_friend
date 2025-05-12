import 'package:flutter/material.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CaptureQrScreen extends ConsumerWidget {
  const CaptureQrScreen({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture QR Code'),
        centerTitle: true,
      ),
      body: MobileScanner(
        onDetect: (barcode) {
          if (barcode.barcodes.first.rawValue != null) {
            final String code = barcode.barcodes.first.rawValue!;
            final uid = code.split('+')[0];
            final password = code.split('+')[1];
            FirestoreHelper().getPassword(uid).then((value) {
              if (value == password) {
                
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid QR code!'),
                  ),
                );
              }
            });
            // Handle the scanned QR code here
          }
        },
      ),
    );
  }
}