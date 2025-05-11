import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';

@riverpod
class ProfileProvider extends Notifier<Map<String, dynamic>> {
  @override
  Map<String, dynamic> build() => {};

  //keep user's basic profile
  Future<void> loadUsersProfile (
    String userUID
  ) async{

    if(userUID == '') {
      return;
    }
    
    //get user data from firebase
    var profile = await FirestoreHelper().getUserProfile(userUID);

    //save to riverpod
    state = profile;
  }
  
}
final profileProvider = NotifierProvider<ProfileProvider, Map<String, dynamic>>(
  ProfileProvider.new,
);
