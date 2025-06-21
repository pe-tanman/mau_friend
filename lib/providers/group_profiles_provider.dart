import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';

class GroupProfile {
  String? name;
  String? iconLink;
  List<String>? memberList;

  GroupProfile({
    this.name,
    this.iconLink,
    this.memberList,
  });
}

class GroupProfilesProvider extends Notifier<Map<String, GroupProfile>> {
  @override
  Map<String, GroupProfile> build() => {};

  Future<void> loadGroupProfiles() async {
    Map profilesMap = await FirestoreHelper().getGroupProfiles();

    Map<String, GroupProfile> result = {};

    profilesMap.forEach((key, profile) {
      result[key] = GroupProfile(
        name: profile['name'],
        iconLink: profile['iconLink'],
        memberList: List<String>.from(profile['memberList'] ?? []),
      );
    });
    state = result;
  }

  Future<void> addGroupMembers(String groupId, List<String> memberList) async {
    state = state.map((key, profile) {
      if (key == groupId) {
        profile.memberList = memberList;
      }
      return MapEntry(key, profile);
    });
  }

  Future<void> editGroupProfile(
    String groupId,
    String name,
    String iconLink,
  ) async {
    state = state.map((key, profile) {
      if (key == groupId) {
        profile.name = name;
        profile.iconLink = iconLink;
      }
      return MapEntry(key, profile);
    });
  }
}

final groupProfilesProvider =
    NotifierProvider<GroupProfilesProvider, Map<String, GroupProfile>>(
      GroupProfilesProvider.new,
    );

class CurrentGroupIdProvider extends Notifier<String> {
  @override
  String build() {
    // Initialize with null or a default value
    return 'null';
  }

  void setCurrentGroupId(String groupId) {
    state = groupId;
  }
}

final currentGroupIdProvider = NotifierProvider<CurrentGroupIdProvider, String>(
  CurrentGroupIdProvider.new,
);
