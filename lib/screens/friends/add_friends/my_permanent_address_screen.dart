import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mau_friend/providers/friend_list_provider.dart';
import 'package:mau_friend/providers/notification_provider.dart';
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
    final myUsername = ref.read(profileProvider).name;
    //FirestoreHelper().updatePassword(uid, password);
    setState(() {
      address = '$myUsername+$password';
    });
    FirestoreHelper().updatePermanentAddress(myUID, address);
  }

  Future<void> loadMyAddress() async {
    await ref.read(profileProvider.notifier).loadMyProfile();
    myUID = FirebaseAuth.instance.currentUser!.uid;
    DatabaseReference dbRef = FirebaseDatabase.instance.ref('users');

    dbRef.onValue.listen((event) {
      FirebaseFirestore.instance
          .collection('friendList')
          .doc(myUID)
          .snapshots()
          .listen((snapshot) {
            ref.read(friendListProvider.notifier).loadFriendList();
            ref.read(friendProfilesProvider.notifier).loadFriendProfiles();
          });
    });
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
              : Center(
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
                            shape: PrettyQrRoundedSymbol(
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
                            Text(
                              address,
                              style: TextStyle(
                                color: AppColors.themeColor,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(width: 10),
                            IconButton(icon: Icon(Icons.copy, color: AppColors.themeColor,), onPressed: (){
                            Clipboard.setData(ClipboardData(text: address));
                            },)
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
