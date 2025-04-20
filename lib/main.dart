import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mi_hospital/domain/sqlite/Sqlite.dart';
import 'package:mi_hospital/firebase_options.dart';
import 'package:mi_hospital/presentation/screen/main_menu.dart';

import 'package:mi_hospital/presentation/screen/sign_in.dart';
import 'package:mi_hospital/presentation/theme/Theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
     var userLogin = DatabaseHelper().getFirstUser();
    return MaterialApp(
      title: 'Mi Hospital',
      debugShowCheckedModeBanner: false,
      theme: ThemeHospital(color: 5).themeData(),
      home: userLogin != null ? MainMenuScreen() :SignInScreen(),
    );
  }
}
