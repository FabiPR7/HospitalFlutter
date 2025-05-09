import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:mi_hospital/domain/Data/DataFuture.dart';
import 'package:mi_hospital/firebase_options.dart';
import 'package:mi_hospital/sections/menu_main/presentation/main_menu.dart';
import 'package:mi_hospital/sections/profile/presentation/profile.dart';
import 'package:mi_hospital/sections/settings/presentation/setting.dart';
import 'package:mi_hospital/sections/sign_in/presentation/sign_in.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';

var datos;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
 
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
   datos =  await LoadData().data();
  runApp(const MyApp());
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Hospital',
      debugShowCheckedModeBanner: false,
      theme: ThemeHospital(color: 5).themeData(),
      home: datos["userLogin"] != null ? MainMenuScreen() : SignInScreen(),
    );
  }
}

class GetData{
  getHospitalCode(){
    return datos["hospitalCode"];
  }

  getUserLogin(){
    return datos["userLogin"];
  }

   getStaffList(){
    return datos["staffList"];
  }
   getPatients(){
    return datos["patientsList"];
  }

  getHospitalName(){
    return datos["hospitalName"];
  }
  rechargeData() async {
    datos =  await LoadData().data();
  }

}