import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/screens/home_screen.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/utilities/statics.dart';

class FriendProfileScreen extends ConsumerStatefulWidget {
  static const routeName = 'friend-profile-screen';

  const FriendProfileScreen({super.key});
  _FriendProfileScreenState createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends ConsumerState<FriendProfileScreen> {
  late Map<String, dynamic> profile;
  bool isLoading = true;
  bool isPermanent = false;
  String message = '';

  Future<void> loadFriendProfile() async {
    final arguments = ModalRoute.of(context)?.settings.arguments! as List;
    final String friendUID = arguments[0];
    isPermanent = arguments[1];
    final friendProfile = await FirestoreHelper().getUserProfile(friendUID);
    setState(() {
      profile = friendProfile;
      isLoading = false;
    });
  }

  Future<void> sendFriendRequest() async {
    if (message.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Please enter a message')));
      return;
    }

    final title = 'Friend Request';
    final body = '${profile['username']} has sent you a friend request.';
    final imageUrl = profile['iconLink'] ?? Statics.defaultIconLink;
    final receiver = profile['userUID'];

    await FirestoreHelper().addMessage(
      title: title,
      body: body,
      imageUrl: imageUrl,
      type: 'Friend Request',
      receivers: [receiver],
      message: message,
    );
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Friend request sent')));
    Navigator.of(context).pushNamed(HomeScreen.routeName);
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
    Navigator.of(context).pushNamed(HomeScreen.routeName);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      loadFriendProfile();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Friend Profile'),
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
                        SizedBox(height: 60),
                        if (isPermanent) ...[
                          Text(
                            'Friend request message should include your full name and relationship with the person.',
                          ),
                          SizedBox(height: 20),
                          TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Friend Request Message',
                            ),
                            onChanged: (value) {
                              setState(() {
                                message = value;
                              });
                            },
                          ),
                          SizedBox(height: 20),
                        ],
                        ElevatedButton(
                          child:
                              isPermanent
                                  ? Text('Send Friend Request')
                                  : Text('Add Friend'),
                          onPressed:
                              isPermanent ? sendFriendRequest : addFriend,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
