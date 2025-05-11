import 'package:mau_friend/utilities/location_helper.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';

@riverpod
class MyStatusProvider extends Notifier<UserStatus> {
  @override
  UserStatus build() => UserStatus('🔴', 'offline');

  //keep user's basic profile
 Future<void> updateMyStatus(UserStatus status) async {
    //save to riverpod
    state = status;
  }
}

final myStatusProvider = NotifierProvider<MyStatusProvider, UserStatus>(
  MyStatusProvider.new,
);
