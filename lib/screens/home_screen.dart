import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flashy_flushbar/flashy_flushbar_widget.dart';
import 'package:flutter/material.dart';
import 'package:mau_friend/screens/friends/friends_screen.dart';
import 'package:mau_friend/screens/myaccount/myaccount_screen.dart';
import 'package:mau_friend/utilities/statics.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = 'home-screen';
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final _screens = [FriendsScreen(), MyAccountScreen()];

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void initState() {
    super.initState();
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      
      print('Received message: ${message.notification?.title}');
      if (message.notification != null) {
        if (message.notification!.title!.contains('Feeling Unsafe')) {
            FlashyFlushbar(
            leadingWidget: const Icon(
              Icons.emergency,
              color: Colors.red,
              size: 24,
            ),
            message: '${message.notification!.body}',
            duration: const Duration(seconds: 3),
            isDismissible: true,
          ).show();
        }
        if(message.notification!.title!.contains('Friend Request')){
          final String iconLink = message.data['imageUrl'] ?? Statics.defaultIconLink;
          FlashyFlushbar(
            leadingWidget:  CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
               iconLink,
              ),
            ),
            message: '${message.notification!.title}',
            duration: const Duration(seconds: 3),
            isDismissible: true,
          ).show();

          
        }
      }
    });
  }

  Widget build(BuildContext context) {
    
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Theme.of(context).colorScheme.primary,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Friends'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Me',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: (index) {
          _onItemTapped(index);
        },
      ),
    );
  }
}
 