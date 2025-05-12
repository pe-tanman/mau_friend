import 'dart:math';

import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/themes/app_theme.dart';

class MyQrScreen extends ConsumerStatefulWidget {
  const MyQrScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyQrScreen> createState() => _MyQrScreenState();
}

class _MyQrScreenState extends ConsumerState<MyQrScreen> {
  bool isInit = true;
  String myUID = '';

  String getMyQRData(String uid) {
    // Generate a random password
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final password = List.generate(10, (index) => chars[random.nextInt(chars.length)]).join();

    FirestoreHelper().updatePassword(uid, password);
    return '$uid+$password';
  }

  

  @override
  void dispose() {
    FirestoreHelper().updatePassword(ref.read(profileProvider).userUID, '');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if(isInit){
 myUID = ref.read(profileProvider).userUID;
isInit = false;
    }
    

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 70),
        SizedBox(width: 300, height:300, child: PrettyQrView.data(data: getMyQRData(myUID), decoration: const PrettyQrDecoration(
          shape:  PrettyQrSmoothSymbol(roundFactor: 0),
        ))),
        const SizedBox(height: 40),
        const Text(
          'Keep this page until you successfully add friends',
        ),
      ],
    );
  }
}
