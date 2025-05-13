import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
class Profile {
  String userUID;
  String? name;
  String? bio;
  String? iconLink;

  Profile({required this.userUID, this.name, this.bio, this.iconLink});
}

@riverpod
class MyProfileProvider extends Notifier<Profile> {
  @override
  Profile build() => Profile(userUID: '', name: '', bio: '', iconLink: '');

  //keep user's basic profile
  Future<void> loadMyProfile() async {
    final myUID = FirebaseAuth.instance.currentUser?.uid;

    //get user data from firebase
    var profile = await FirestoreHelper().getUserProfile(myUID!);
print('iconLink: ${profile['iconLink']}');
print('name: ${profile['username']}');
    print('bio: ${profile['bio']}');
    //save to riverpod
    state = Profile(
      userUID: myUID,
      name: profile['username'],
      bio: profile['bio'],
      iconLink: profile['iconLink'],
    );
  }
}

final profileProvider = NotifierProvider<MyProfileProvider, Profile>(
  MyProfileProvider.new,
);

class FriendProfilesProvider extends Notifier<Map<String, Profile>> {
  @override
  Map<String, Profile> build() => {};

  Future<void> loadFriendProfiles() async {
    var profilesMap = await FirestoreHelper().getFriendProfiles();

    Map<String, Profile> result = {};

    profilesMap.values.map((profile) {
      result[profile['userUID']] = Profile(
        userUID: profile['userUID'],
        name: profile['name'],
        bio: profile['bio'],
        iconLink: profile['iconLink'],
      );
    });

    state = result;
  }
}

final friendProfilesProvider =
    NotifierProvider<FriendProfilesProvider, Map<String, Profile>>(
      FriendProfilesProvider.new,
    );
