import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:mau_friend/screens/home_screen.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/utilities/statics.dart';

class FriendDetailScreen extends ConsumerStatefulWidget {
  static const routeName = 'friend-detail-screen';

  const FriendDetailScreen({super.key});
  _FriendDetailScreenState createState() => _FriendDetailScreenState();
}

class _FriendDetailScreenState extends ConsumerState<FriendDetailScreen> {
  late Map<String, dynamic> profile;
  bool isLoading = true;

  Future<void> loadFriendProfile() async {
    final arguments = ModalRoute.of(context)?.settings.arguments! as String;
    final String friendUID = arguments;
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
        title: Text('Friend Detail'),
      ),
      body:
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Center(
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 80,
                          backgroundImage: NetworkImage(
                            profile['iconLink'] ??
                                Statics.defaultIconLink, // default icon link
                          ),
                        ), // a cat image
                        SizedBox(height: 20),
                        Text(
                          profile['username'] ?? 'Username',
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 15),
                        Text(
                          overflow: TextOverflow.clip,
                          profile['bio'] ?? 'Bio',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
