import 'package:annahomestay/firebase_options.dart';
import 'package:annahomestay/login/loginPage.dart';
import 'package:annahomestay/models/availabilityscreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'admin/dashboard.dart';
import 'user/bookingScreen.dart';
import 'user/confirmationScreen.dart';
import 'user/descriptionScreen.dart';
import 'user/listScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginPage(), //nanti tukar balik jadi SignUpPage()
      debugShowCheckedModeBanner: false,
      routes: {
        '/list': (context) => ListScreen(),
        '/booking': (context) => BookingScreen(),
        '/confirmation': (context) => ConfirmationScreen(),
        '/description': (context) => DescriptionScreen(),
      },
    );
  }
}
