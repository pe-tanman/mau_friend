import 'package:flutter/material.dart';
import 'package:mau_friend/screens/friends_screen.dart';
import 'package:mau_friend/screens/myaccount_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const routeName = 'home-screen';
  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Widget build(BuildContext context) {
    final _screens = [FriendsScreen(), MyAccountScreen()];

    int _selectedIndex = 0;

    return Scaffold(
      appBar: AppBar(title: const Text('🐈 mau')),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Friends'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle),
            label: 'Me',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          print(_selectedIndex);
        },
      ),
    );
  }
}
