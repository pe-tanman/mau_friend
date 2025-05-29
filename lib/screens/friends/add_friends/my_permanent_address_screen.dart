import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mau_friend/themes/app_color.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';

class MyPermanentAddressScreen extends ConsumerStatefulWidget {
  static const routeName = '/my-permanent-address';
  const MyPermanentAddressScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<MyPermanentAddressScreen> createState() =>
      _MyPermanentAddressScreenState();
}

class _MyPermanentAddressScreenState
    extends ConsumerState<MyPermanentAddressScreen> {
  bool isInit = true;
  bool isLoading = true;
  String myUID = '';
  String address = '';

  void updateMyAddress() {

    // Generate a random password
    const chars =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    final password =
        List.generate(5, (index) => chars[random.nextInt(chars.length)]).join();
    final myUID = FirebaseAuth.instance.currentUser!.uid;
    //FirestoreHelper().updatePassword(uid, password);
    setState(() {
      address = '$myUID+$password';
    });
    FirestoreHelper().updatePermanentAddress(myUID, address);
  }

  Future<void> loadMyAddress() async {
    await ref.read(profileProvider.notifier).loadMyProfile();
    myUID = FirebaseAuth.instance.currentUser!.uid;

    String myAddress = await FirestoreHelper().getPermanentAddress(myUID);
    if (myAddress != '') {
      address = myAddress;
    } else {
      updateMyAddress();
      print('Address is empty, generating new address');
      print('my uid: $myUID');
    }

    setState(() {
      isInit = false;
      isLoading = false;
    });
  }

  @override
  void dispose() {
    FirestoreHelper().updatePassword(myUID, '');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isInit) {
      loadMyAddress();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Permanent Code'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              updateMyAddress();
            },
          ),
        ],
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(20.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(height: 70),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                          color: AppColors.backgroundColor,
                        ),
                        width: 350,
                        height: 350,
                        child: Padding(
                          padding: const EdgeInsets.all(25.0),
                          child: PrettyQrView.data(
                            data: address,
                            decoration: const PrettyQrDecoration(
                              shape: PrettyQrSmoothSymbol(
                                roundFactor: 0,
                                color:  AppColors.themeColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      Text('Or copy your address and share with your friends:'),
                      const SizedBox(height: 20),
                      Container(
                        color: AppColors.backgroundColor,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                address,
                                style: TextStyle(
                                  color: AppColors.themeColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.visible,
                                softWrap: true,
                                ),
                              ),
                              SizedBox(width: 10),
                              IconButton(icon: Icon(Icons.copy, color: AppColors.themeColor,), onPressed: (){
                              Clipboard.setData(ClipboardData(text: address));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Copied!'), duration: Duration(seconds: 1))
                              );
                              },)
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
