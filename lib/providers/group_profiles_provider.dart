import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupProfile {
  String groupId;
  String? name;
  String? iconLink;

  GroupProfile({required this.groupId, this.name, this.iconLink});
}

class GroupProfilesProvider extends Notifier<Map<String, GroupProfile>> {
  @override
  Map<String, GroupProfile> build() => {};

  Future<void> loadGroupProfiles() async {
    Map profilesMap = await FirestoreHelper().getGroupProfiles();

    Map<String, GroupProfile> result = {};

    profilesMap.forEach((key, profile) {
      result[key] = GroupProfile(
        groupId: profile['groupId'],
        name: profile['name'],
        iconLink: profile['iconLink'],
      );
    });

    state = result;
  }
}

final groupProfilesProvider =
    NotifierProvider<GroupProfilesProvider, Map<String, GroupProfile>>(
      GroupProfilesProvider.new,
    );
