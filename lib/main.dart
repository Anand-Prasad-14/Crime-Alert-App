import 'package:flutter/material.dart';
import 'package:secure_alert/authenticate/views/login_screen.dart';
import 'package:secure_alert/authenticate/views/register_screen.dart';
import 'package:secure_alert/authenticate/views/splash_scrreen.dart';
import 'package:secure_alert/crime_alert/views/crime_alert_view.dart';
import 'package:secure_alert/home.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Defender3601',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomePage(),
        '/login':(context) => const LoginScreen(),
        '/register':(context) => const RegisterScreen(),
        
        '/crimeAlert':(context) => const CrimeAlertView(),
        
      },
    );
  }
}
