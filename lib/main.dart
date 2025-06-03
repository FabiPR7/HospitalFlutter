import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:mi_hospital/domain/Data/DataFuture.dart';
import 'package:mi_hospital/firebase_options.dart';
import 'package:mi_hospital/sections/Menu_main/presentation/main_menu.dart';
import 'package:mi_hospital/sections/Profile/presentation/profile.dart';
import 'package:mi_hospital/sections/Settings/presentation/setting.dart';
import 'package:mi_hospital/sections/Sign_in/presentation/sign_in.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'package:firebase_database/firebase_database.dart';

var datos;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  datos = await LoadData().data();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mi Hospital',
      debugShowCheckedModeBanner: false,
      theme: ThemeHospital(color: 5).themeData(),
      home: datos["userLogin"] != null ? MainMenuScreen() : SignInScreen(),
    );
  }
}

class GetData {
  getHospitalCode() {
    return datos["hospitalCode"];
  }

  getUserLogin() {
    return datos["userLogin"];
  }

  getStaffList() {
    return datos["staffList"];
  }

  getPatients() {
    return datos["patientsList"];
  }

  getHospitalName() {
    return datos["hospitalName"];
  }

  rechargeData() async {
    datos = await LoadData().data();
  }

  updateUserData(Map<String, dynamic> newData) async {
    if (datos["userLogin"] != null) {
      final userCode = datos["userLogin"]["codigo"];
      final databaseRef = FirebaseDatabase.instance.ref();
      final snapshot = await databaseRef.child('users').orderByChild('codigo').equalTo(userCode).once();
      
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final userId = data.keys.first;
        await databaseRef.child('users/$userId').update(newData);
        
        Map<String, dynamic> updatedUserData = Map<String, dynamic>.from(datos["userLogin"]);
        updatedUserData.addAll(newData);
        datos["userLogin"] = updatedUserData;
      }
    }
  }
}