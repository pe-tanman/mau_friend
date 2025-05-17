import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:mau_friend/providers/notification_provider.dart';
import 'package:mau_friend/themes/app_color.dart';
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
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final password =
        List.generate(
          10,
          (index) => chars[random.nextInt(chars.length)],
        ).join();

    FirestoreHelper().updatePassword(uid, password);
    return '$uid+$password';
  }

  @override
  void dispose() {
    FirestoreHelper().updatePassword(myUID, '');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      ref.read(profileProvider.notifier).loadMyProfile().then((_) {
        setState(() {
          myUID = ref.read(profileProvider).userUID;
          isInit = false;
        });
      });
    }

    return isInit
        ? Center(child: CircularProgressIndicator())
        : Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 70),
        Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(30)), color: AppColors.backgroundColor),
          width: 350,
          height: 350,
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: PrettyQrView.data(
              data: getMyQRData(myUID),
              decoration: const PrettyQrDecoration(
            
                shape: PrettyQrSmoothSymbol(roundFactor: 0, color: AppColors.themeColor),
              ),
            ),
          ),
        ),
        const SizedBox(height: 40),
        const Text('Keep this page until you successfully add friends'),
      ],
    );
  }
}
