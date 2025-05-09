import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mau_friend/screens/authGate.dart';
import 'package:mau_friend/screens/welcome_screen.dart';
import 'firebase_options.dart';
import 'package:mau_friend/screens/home_screen.dart';
import 'package:mau_friend/screens/myaccount_screen.dart';
import 'package:mau_friend/screens/map_screen.dart';
import 'package:mau_friend/themes/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        isLoggedIn = user != null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme(),
      routes: {
        WelcomeScreen.routeName: (context) => WelcomeScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        AuthGate.routeName: (context) => AuthGate(),
        MyAccountScreen.routeName: (context) => MyAccountScreen(),
        MapScreen.routeName: (context) => MapScreen(),
      },
      home: isLoggedIn ? HomeScreen() : WelcomeScreen(),
    );
  }
}
