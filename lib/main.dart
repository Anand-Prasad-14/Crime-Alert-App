import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:secure_alert/account/components/webview.dart';
import 'package:secure_alert/account/views/account_screen.dart';
import 'package:secure_alert/account/views/edit_profile_view.dart';
import 'package:secure_alert/account/views/edit_soscontent_view.dart';
import 'package:secure_alert/account/views/help_center_view.dart';
import 'package:secure_alert/account/views/manage_view.dart';
import 'package:secure_alert/authenticate/views/login_screen.dart';
import 'package:secure_alert/authenticate/views/register_screen.dart';
import 'package:secure_alert/authenticate/views/splash_scrreen.dart';
import 'package:secure_alert/crime_alert/views/crime_alert_view.dart';
import 'package:secure_alert/crime_report/views/crime_report_view.dart';
import 'package:secure_alert/home.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/service/logger.dart';
import 'package:secure_alert/social_feed/views/my_post_view.dart';
import 'package:secure_alert/social_feed/views/post_feed_view.dart';
import 'package:dcdg/dcdg.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyC9l94A3DGGGiospTeV0yzChpOq31PvU4g',
          appId: '1:468402823127:android:f796c18d48ec78cbfd3592',
          messagingSenderId: '468402823127',
          projectId: 'crime-alert-e1c3c',
          storageBucket: 'crime-alert-e1c3c.appspot.com'));

  //awesome notifications
  await AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests')
  ]);

  

  bool isAllowedToSendNotification = await AwesomeNotifications().isNotificationAllowed();
  if (!isAllowedToSendNotification) {
    AwesomeNotifications().requestPermissionToSendNotifications();
  }
  runApp(const MyApp());
}

  Future<void> _init() async {
    var log = logger();
    log.i('App init');
    var global = Global();
    await global.init();
  }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  asyncInit() async {
    await _init();
  }

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'India Alert',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/account': (context) => const AccountScreen(),
        '/crimeAlert': (context) => const CrimeAlertView(),
        '/crimeReport': (context) => const CrimeReportScreen(),
        '/helpCenter': (context) => const HelpCenterView(),
        '/editProfile': (context) => const EditProfile(),
        '/postFeed':(context) => const PostFeedScreen(),
        '/postList':(context) => const PostFeedScreen(),
        '/manageContact':(context) => const ManageEmergencyContact(),
        '/editSOS':(context) => const EditSOSContent(),
        '/myPost':(context) => const PostScreen(),
        '/guide':(context) => const GuideWebView()
      },
    );
  }
}
