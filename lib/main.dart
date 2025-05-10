import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mau_friend/screens/add_location_screen.dart';
import 'package:mau_friend/screens/authGate.dart';
import 'package:mau_friend/screens/profile_setting_screen.dart';
import 'package:mau_friend/screens/setting_screen.dart';
import 'package:mau_friend/screens/welcome_screen.dart';
import 'firebase_options.dart';
import 'package:mau_friend/screens/home_screen.dart';
import 'package:mau_friend/screens/myaccount_screen.dart';
import 'package:mau_friend/themes/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
   if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  dotenv.load(fileName: 'lib/credential.env');
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
   MyApp({super.key});
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
        AddLocationScreen.routeName: (context) => AddLocationScreen(),
        SettingScreen.routeName: (context) => SettingScreen(),
        ProfileSettingScreen.routeName: (context) =>
            ProfileSettingScreen(),
      },
      home: isLoggedIn ? HomeScreen() : WelcomeScreen(),
    );
  }
}
