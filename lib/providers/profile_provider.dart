import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';

@riverpod
class ProfileProvider extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => {};

  //keep user's basic profile
  Future<String> loadUsersProfile(String userUID) async {
    if (userUID == '') {
      return 'no data';
    }

    //get user data from firebase
    var profile = await FirestoreHelper().getUserProfile(userUID);

    //save to riverpod
    state = profile;
    return 'success';
  }
}

final profileProvider = NotifierProvider<ProfileProvider, Map<String, dynamic>>(
  ProfileProvider.new,
);
