import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/notification_provider.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/themes/app_theme.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/utilities/statics.dart';

class FriendProfileScreen extends ConsumerStatefulWidget {
  @override
  static const routeName = 'friend-profile-screen';
  _FriendProfileScreenState createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends ConsumerState<FriendProfileScreen> {

late Map<String, dynamic> profile;
bool isLoading = true;
  Future<void> loadFriendProfile() async {
    final arguments = ModalRoute.of(context)?.settings.arguments;
    final String friendUID = arguments! as String;
    final friendProfile = await FirestoreHelper().getUserProfile(friendUID);
    setState(() {
      profile = friendProfile;
      isLoading = false;
    });
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
      body: isLoading? Center(child: CircularProgressIndicator()): Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 20),
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
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text(
              profile['bio'] ?? 'Bio',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 60),
            ElevatedButton(child:Text('Add'), onPressed: (){
              // Add friend logic here
              FirestoreHelper().addFriendList(profile['userUID']);
              Navigator.of(context).pop();
              Navigator.of(context).pop();
          
            })
          ],
        ),
      ),
    );
  }
}
