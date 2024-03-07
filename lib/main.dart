import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:secure_alert/account/views/account_screen.dart';
import 'package:secure_alert/account/views/edit_profile_view.dart';
import 'package:secure_alert/account/views/help_center_view.dart';
import 'package:secure_alert/authenticate/views/login_screen.dart';
import 'package:secure_alert/authenticate/views/register_screen.dart';
import 'package:secure_alert/authenticate/views/splash_scrreen.dart';
import 'package:secure_alert/crime_alert/views/crime_alert_view.dart';
import 'package:secure_alert/crime_report/views/crime_report_view.dart';
import 'package:secure_alert/home.dart';
import 'package:secure_alert/service/global.dart';
import 'package:secure_alert/service/logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  //awesome notifications
  AwesomeNotifications().initialize(null, [
    NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Basic notifications',
        channelDescription: 'Notification channel for basic tests')
  ]);
  runApp(const MyApp());
}

_init() async {
  var log = logger();
  log.i('App init');
  var global = Global();
  await global.init();
  return Future.value(null);
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
      title: 'Defender3601',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/account': (context) => const AccountScreen(),
        '/crimeAlert': (context) => const CrimeAlertView(),
        '/crimeReport':(context) => const CrimeReportScreen(),
        '/helpCenter': (context) => const HelpCenterView(),
        '/editProfile': (context) => const EditProfile()
      },
    );
  }
}
