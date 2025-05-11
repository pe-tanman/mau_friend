import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mau_friend/providers/locations_provider.dart';
import 'package:mau_friend/screens/add_location_screen.dart';
import 'package:mau_friend/screens/authGate.dart';
import 'package:mau_friend/screens/current_location_screen.dart';
import 'package:mau_friend/screens/profile_setting_screen.dart';
import 'package:mau_friend/screens/setting_screen.dart';
import 'package:mau_friend/screens/welcome_screen.dart';
import 'firebase_options.dart';
import 'package:mau_friend/screens/home_screen.dart';
import 'package:mau_friend/screens/myaccount_screen.dart';
import 'package:mau_friend/themes/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  dotenv.load(fileName: 'lib/credential.env');
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        isLoggedIn = user != null;
      });
    });
    print('isLoggedIn: ${FirebaseAuth.instance.currentUser?.uid}');
     // Load user profile data
    // Load user profile data when the user is logged in)
  }

  @override
  Widget build(BuildContext context) {
    ref
        .watch(profileProvider.notifier)
        .loadUsersProfile(FirebaseAuth.instance.currentUser?.uid ?? '');
        ref
        .watch(locationsProvider.notifier)
        .loadLocations();
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
        ProfileSettingScreen.routeName: (context) => ProfileSettingScreen(),
        CurrentLocationScreen .routeName: (context) => CurrentLocationScreen(),
      },
      home: isLoggedIn ? HomeScreen() : WelcomeScreen(),
    );
  }
}
