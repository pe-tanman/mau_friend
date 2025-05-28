import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/notification_provider.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/themes/app_color.dart';
import 'package:mau_friend/themes/app_theme.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/utilities/statics.dart';

class FriendRequestScreen extends ConsumerStatefulWidget {
  @override
  static const routeName = 'friend-request-screen';
  _FriendRequestScreenState createState() => _FriendRequestScreenState();
}

class _FriendRequestScreenState extends ConsumerState<FriendRequestScreen> {
  late Map<String, dynamic> profile;
  bool isLoading = true;
  String message = '';

  Future<void> loadFriendProfile() async {
    final arguments = ModalRoute.of(context)?.settings.arguments! as List;
    final String friendUID = arguments[0];
    final friendProfile = await FirestoreHelper().getUserProfile(friendUID);
    setState(() {
      profile = friendProfile;
      message = arguments[1];
      isLoading = false;
    });
  }
  Future<void> addFriend() async {
    ref.read(profileProvider.notifier).loadMyProfile();

    FirestoreHelper().addFriendList(profile['userUID']);
   
    final myProfile = ref.read(profileProvider);
    FirestoreHelper().addNotification(
      'New Friend',
      '${myProfile.name} is now your friend.',
      myProfile.iconLink ?? Statics.defaultIconLink,
      'New Friend',
      [profile['userUID']],
      FirebaseAuth.instance.currentUser!.uid,
    );
    FirestoreHelper().addNotification(
      'New Friend',
      '${profile['username']} is now your friend.',
      profile['iconLink'] ?? Statics.defaultIconLink,
      'New Friend',
      [FirebaseAuth.instance.currentUser!.uid],
      FirebaseAuth.instance.currentUser!.uid,
    );
    
    Navigator.of(context).pop();
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      loadFriendProfile();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Requst'),
        automaticallyImplyLeading: false,
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(
                            profile['iconLink'] ??
                                Statics.defaultIconLink, // default icon link
                          ),
                        ), // a cat image
                        SizedBox(height: 10),
                        Text(
                          profile['username'] ?? 'Username',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          profile['bio'] ?? 'Bio',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        SizedBox(height: 20),
                        Text(message),
                        SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                          OutlinedButton(onPressed: (){
                            Navigator.of(context).pop();
                          }, child: Text('Reject')),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: addFriend, child: Text('Accept')),
                        ],)
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
