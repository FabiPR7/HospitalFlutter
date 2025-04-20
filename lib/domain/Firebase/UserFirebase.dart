// ignore_for_file: file_names, avoid_print, unused_local_variable

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/domain/entities/User.dart';
import 'package:mi_hospital/presentation/widgets/log_Sign/widgets_Log_In.dart';

class Userfirebase {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<bool> registerUser(UserEntity user, String password, context) async {
    try {
      bool resultCode = await existCode(user.code);
      if (resultCode) {
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
              email: user.email,
              password: password,
            );
        String userId = userCredential.user!.uid;
        insertUser(user, userId);
      } else {
        WidgetsLogIn().getToastMessage(
          context,
          "Este código de verificación ya esta en uso.",
        );
        return false;
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        // Muestra un mensaje al usuario
        WidgetsLogIn().getToastMessage(
          context,
          "El correo electrónico ya está en uso.",
        );
        return false;
      }
    } catch (e) {
      print("Error inesperado: $e");
      return false;
    }
    return true;
  }

  Future<bool> loginUser(email, pwd, context) async {
    try {
      UserCredential usercredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: pwd.trim(),
      );
      WidgetsLogIn().getToastMessage(context, "Iniciando sesión...");
    } on FirebaseAuthException {
      WidgetsLogIn().getToastMessage(
        context,
        "El correo electrónico o la contraseña no son correctos, intentalo de nuevo.",
      );
      return false;
    } catch (e) {
      WidgetsLogIn().getToastMessage(context, "Error no controlado: $e");
      return false;
    }
    return true;
  }

  insertUser(user, userId) {
    _databaseReference
        .child('users')
        .child(userId)
        .set(user.getUserFjson())
        .then((_) {})
        .catchError((error) {});
  }

  Future<bool> existCode(String code) async {
    try {
      final snapshot =
          await _databaseReference
              .child('users')
              .orderByChild('codigo')
              .equalTo(code)
              .once();
      return snapshot.snapshot.value == null;
    } catch (error) {
      // Si ocurre un error, asumimos que el código no existe
      print('Error al verificar el código: $error');
      return false;
    }
  }
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
  try {
    final DatabaseReference usersRef = FirebaseDatabase.instance.ref().child('users');
    final DatabaseEvent event = await usersRef
        .orderByChild('email')
        .equalTo(email)
        .once();
    if (event.snapshot.value != null) {
      final Map<dynamic, dynamic> users = event.snapshot.value as Map<dynamic, dynamic>;
      final Map<dynamic, dynamic> userData = users.values.first;
      return {
        'codigo': userData['codigo']?.toString(),
        'email': userData['email']?.toString(),
        'name': userData['name']?.toString(),
      };
    } else {
      return null; 
    }
  } catch (e) {
    print('Error al buscar usuario: $e');
    return null;
  }
}
}
