import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';

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
  Future<String> loadUsersProfile(String userUID) async {
    if (userUID == '') {
      return 'no data';
    }

    //get user data from firebase
    var profile = await FirestoreHelper().getUserProfile(userUID);

    //save to riverpod
    state = Profile(
      userUID: userUID,
      name: profile['name'],
      bio: profile['name'],
      iconLink: profile['iconLink'],
    );
    return 'success';
  }
}

final profileProvider = NotifierProvider<MyProfileProvider, Profile>(
  MyProfileProvider.new,
);

class FriendProfilesProvider extends Notifier<List<Profile>> {
  @override
  List<Profile> build() => [];

  Future<void> loadFriendProfiles() async {

    var profilesMap = await FirestoreHelper().getFriendProfiles();

    final profilesList = profilesMap.values.map((profile) {
      return Profile(
        userUID: profile['userUID'] ?? '',
        name: profile['name'] ?? '',
        bio: profile['bio'] ?? '',
        iconLink: profile['iconLink'] ?? '',
      );
    }).toList();

    state = profilesList;
  }
}
final friendProfilesProvider =
    NotifierProvider<FriendProfilesProvider, List<Profile>>(
  FriendProfilesProvider.new,
);
