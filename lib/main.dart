import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:mau_friend/providers/locations_provider.dart';
import 'package:mau_friend/screens/friends/add_friends/add_friend_screen.dart';
import 'package:mau_friend/screens/myaccount/add_location_screen.dart';
import 'package:mau_friend/screens/welcome/authGate.dart';
import 'package:mau_friend/screens/settings/current_location_screen.dart';
import 'package:mau_friend/screens/friends/edit_friend_list_screen.dart';
import 'package:mau_friend/screens/friends/friend_profile_screen.dart';
import 'package:mau_friend/screens/settings/profile_setting_screen.dart';
import 'package:mau_friend/screens/settings/setting_screen.dart';
import 'package:mau_friend/screens/welcome/welcome_screen.dart';
import 'firebase_options.dart';
import 'package:mau_friend/screens/home_screen.dart';
import 'package:mau_friend/screens/myaccount/myaccount_screen.dart';
import 'package:mau_friend/themes/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:mau_friend/providers/profile_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/screens/friends/notification_screen.dart';

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
  ThemeMode mode = ThemeMode.system; // Define the mode variable

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        isLoggedIn = user != null;
      });
    });
     // Load user profile data
    // Load user profile data when the user is logged in)
  }

  @override
  Widget build(BuildContext context) {
        ref
        .watch(locationsProvider.notifier)
        .loadLocations();
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme(),
      darkTheme: darkTheme(),
      themeMode: mode, 
      routes: {
        WelcomeScreen.routeName: (context) => WelcomeScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        AuthGate.routeName: (context) => AuthGate(),
        MyAccountScreen.routeName: (context) => MyAccountScreen(),
        AddLocationScreen.routeName: (context) => AddLocationScreen(),
        SettingScreen.routeName: (context) => SettingScreen(),
        ProfileSettingScreen.routeName: (context) => ProfileSettingScreen(),
        CurrentLocationScreen .routeName: (context) => CurrentLocationScreen(),
        AddFriendScreen.routeName : (context) => AddFriendScreen(),
        FriendProfileScreen.routeName : (context) => FriendProfileScreen(),
        NotificationScreen.routeName : (context) => NotificationScreen(),
        EditFriendListScreen.routeName : (context) => EditFriendListScreen(),
      },
      home: isLoggedIn ? HomeScreen() : WelcomeScreen(),
    );
  }
}
