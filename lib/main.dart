import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as logger;

import 'package:app_links/app_links.dart';
import 'package:background_fetch/background_fetch.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flashy_flushbar/flashy_flushbar_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:home_widget/home_widget.dart';
import 'package:mau_friend/providers/locations_provider.dart';
import 'package:mau_friend/providers/recommendation_enabled_provider.dart';
import 'package:mau_friend/screens/friends/add_friends/add_friend_screen.dart';
import 'package:mau_friend/screens/friends/add_friends/enter_code_screen.dart';
import 'package:mau_friend/screens/friends/add_friends/friend_request_screen.dart';
import 'package:mau_friend/screens/friends/add_friends/my_permanent_address_screen.dart';
import 'package:mau_friend/screens/friends/add_member_group_screen.dart';
import 'package:mau_friend/screens/friends/create_group_screen.dart';
import 'package:mau_friend/screens/friends/emergency_location_screen.dart';
import 'package:mau_friend/screens/friends/friend_detail_screen.dart';
import 'package:mau_friend/screens/myaccount/add_location_screen.dart';
import 'package:mau_friend/screens/myaccount/emergency_screen.dart';
import 'package:mau_friend/screens/myaccount/recommendation_screen.dart';
import 'package:mau_friend/screens/settings/privacy_setting_screen.dart';
import 'package:mau_friend/screens/welcome/authGate.dart';
import 'package:mau_friend/screens/settings/current_location_screen.dart';
import 'package:mau_friend/screens/friends/edit_friend_list_screen.dart';
import 'package:mau_friend/screens/friends/add_friends/friend_profile_screen.dart';
import 'package:mau_friend/screens/settings/profile_setting_screen.dart';
import 'package:mau_friend/screens/settings/setting_screen.dart';
import 'package:mau_friend/screens/welcome/welcome_screen.dart';
import 'package:mau_friend/utilities/custom_widget_info.dart';
import 'package:mau_friend/utilities/firestore_helper.dart';
import 'package:mau_friend/utilities/prefs_helper.dart';
import 'package:mau_friend/utilities/statics.dart';
import 'firebase_options.dart';
import 'package:mau_friend/screens/home_screen.dart';
import 'package:mau_friend/screens/myaccount/myaccount_screen.dart';
import 'package:mau_friend/themes/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mau_friend/screens/friends/notification_screen.dart';

import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:app_links/app_links.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
  await Firebase.initializeApp();
 

  if (message.data.keys.contains('status')) {
    var status = message.data['status'];
    const String iOSWidgetName = 'mau_widget';
   
    if(Platform.isIOS) {
       HomeWidget.saveWidgetData<String>('status', status);
      HomeWidget.updateWidget(iOSName: iOSWidgetName);
    }
    
    // Handle emergency notification
  } else {
    // Handle other types of notifications
  }
}

@pragma('vm:entry-point')
void backgroundFetchHeadlessTask(HeadlessTask task) async {
  String taskId = task.taskId;
  bool isTimeout = task.timeout;
  if (isTimeout) {
    // This task has exceeded its allowed running-time.
    // You must stop what you're doing and immediately .finish(taskId)
    print("[BackgroundFetch] Headless task timed-out: $taskId");
    BackgroundFetch.finish(taskId);
    return;
  }
  print('[BackgroundFetch] Headless event received.');
  // Do your work here...
  BackgroundFetch.finish(taskId);
}
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  //TODO: debug -> production stuff
   await FirebaseAppCheck.instance.activate(
    webProvider: ReCaptchaV3Provider('recaptcha-v3-site-key'),
    androidProvider: AndroidProvider.debug,
    appleProvider: AppleProvider.debug,
  );
  dotenv.load(fileName: 'lib/credential.env');
  await HomeWidget.setAppGroupId('group.mau_widget');

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(ProviderScope(child: MyApp()));
  BackgroundFetch.registerHeadlessTask(backgroundFetchHeadlessTask);
}

class MyApp extends ConsumerStatefulWidget {
  MyApp({super.key});
  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  bool isLoggedIn = false;
  ThemeMode mode = ThemeMode.system; // Define the mode variable
      bool _enabled = true;
  int _status = 0;
  List<DateTime> _events = [];
  late StreamSubscription sub;

  @override
  void initState() {
    super.initState();
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      setState(() {
        isLoggedIn = user != null;
      });
      ref.read(recommendationEnabledProvider.notifier).loadRecommendationPrefs();
    });
    initPlatformState();
  }

    static void onBackgroundFetch(String taskId) async {
    const appGroupId = 'group.mau_widget';
    const String iOSWidgetName = 'mau_widget';
    final firstFriend = await PrefsHelper().getFirstFriend();
    final status = await RealtimeDatabaseHelper().getStatus(firstFriend);
    final firstFriendName =
        await PrefsHelper().getFirstFriendName() ?? 'Username';
    final firstFriendIconLink =
        await PrefsHelper().getFirstFriendIconLink() ?? Statics.defaultIconLink;
    final emoji = status?.icon ?? '🔴';
    final statusText = status?.status ?? 'offline';

    WidgetKit.setItem(
      iOSWidgetName,
      jsonEncode(
        CustomWidgetInfo(
          name: firstFriendName,
          iconLink: firstFriendIconLink,
          status: '$emoji $statusText',
        ),
      ),
      appGroupId,
    );
    WidgetKit.reloadAllTimelines();

    BackgroundFetch.finish(taskId);
  }

  static Future<void> onBackgroundFetchTimeout(String taskId) async {
    print('[BackgroundFetch] TIMEOUT: $taskId');
    BackgroundFetch.finish(taskId);
  }

  Future<void> initPlatformState() async {


    // Configure BackgroundFetch.
    int status = await BackgroundFetch.configure(
      BackgroundFetchConfig(
        minimumFetchInterval: 15,
        stopOnTerminate: false,
        enableHeadless: true,
        requiresBatteryNotLow: false,
        requiresCharging: false,
        requiresStorageNotLow: false,
        requiresDeviceIdle: false,
        requiredNetworkType: NetworkType.NONE,

      ),
      onBackgroundFetch,
      onBackgroundFetchTimeout
    );
    setState(() {
      _status = status;
    });
    if (!mounted) return;
  }



  @override
  Widget build(BuildContext context) {
    ref.watch(locationsProvider.notifier).loadLocations();
    return MaterialApp(
      title: 'mau Friend',
      theme: appTheme(),
      darkTheme: darkTheme(),
      themeMode: mode,
      builder: FlashyFlushbarProvider.init(),
      routes: {
        WelcomeScreen.routeName: (context) => WelcomeScreen(),
        HomeScreen.routeName: (context) => HomeScreen(),
        AuthGate.routeName: (context) => AuthGate(),
        MyAccountScreen.routeName: (context) => MyAccountScreen(),
        AddLocationScreen.routeName: (context) => AddLocationScreen(),
        SettingScreen.routeName: (context) => SettingScreen(),
        ProfileSettingScreen.routeName: (context) => ProfileSettingScreen(),
        CurrentLocationScreen.routeName: (context) => CurrentLocationScreen(),
        AddFriendScreen.routeName: (context) => AddFriendScreen(),
        FriendProfileScreen.routeName: (context) => FriendProfileScreen(),
        NotificationScreen.routeName: (context) => NotificationScreen(),
        EditFriendListScreen.routeName: (context) => EditFriendListScreen(),
        EmergencyScreen.routeName: (context) => EmergencyScreen(),
        EmergencyLocationScreen.routeName:
            (context) => EmergencyLocationScreen(),
        MyPermanentAddressScreen.routeName: (context) => MyPermanentAddressScreen(),
        EnterCodeScreen.routeName: (context) => EnterCodeScreen(),
        FriendRequestScreen.routeName: (context) => FriendRequestScreen(),
        FriendDetailScreen.routeName: (context) => FriendDetailScreen(),
        RecommendationScreen.routeName: (context) => RecommendationScreen(),
        PrivacySettingScreen.routeName: (context) => PrivacySettingScreen(),
        CreateGroupScreen.routeName: (context) => CreateGroupScreen(),
        AddMemberGroupScreen.routeName: (context) => AddMemberGroupScreen(),
      },
      home: isLoggedIn ? HomeScreen() : WelcomeScreen(),
    );
  }
}
