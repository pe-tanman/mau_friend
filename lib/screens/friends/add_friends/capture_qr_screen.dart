import 'package:flutter/material.dart';
import 'package:mau_friend/screens/friends/add_friends/enter_code_screen.dart';
import 'package:mau_friend/screens/friends/friend_profile_screen.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CaptureQrScreen extends ConsumerStatefulWidget {
  const CaptureQrScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<CaptureQrScreen> createState() => _CaptureQrScreenState();
}

class _CaptureQrScreenState extends ConsumerState<CaptureQrScreen> {
  late MobileScannerController cameraController;
  bool isInit = true;
  bool isDetectedFirst = true;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      cameraController = MobileScannerController(
        detectionSpeed: DetectionSpeed.noDuplicates,
      );
      isInit = false;
      return Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).pushNamed(EnterCodeScreen.routeName);
          },
          child: const Icon(Icons.abc),
        ),
        body: MobileScanner(
          controller: cameraController,
          onDetect: (barcode) {
            if (barcode.barcodes.first.rawValue != null && isDetectedFirst) {
              isDetectedFirst = false;
              final String code = barcode.barcodes.first.rawValue!;
              final uid = code.split('+')[0];
              final password = code.split('+')[1];

              if (password.length == 10) {
                FirestoreHelper().getPassword(uid).then((value) {
                  if (value == password) {
                    Navigator.pushNamed(
                      context,
                      FriendProfileScreen.routeName,
                      arguments: [uid, false],
                    );
                    return;
                  }
                });
              }
              else if(password.length == 5){
                FirestoreHelper().getPermanentAddress(uid).then((value) {
                  if (value == code) {
                    Navigator.pushNamed(
                      context,
                      FriendProfileScreen.routeName,
                      arguments: [uid, true],
                    );
                    return;
                  }
                });
              }
              else{
                 ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invalid QR code. Try again.')),
                );
                Navigator.of(context).pop();
              }
            }
          },
        ),
      );
    } else {
      return const Center(
        child: Text('Camera is not initialized\n     reopen this page'),
      );
    }
  }
}
