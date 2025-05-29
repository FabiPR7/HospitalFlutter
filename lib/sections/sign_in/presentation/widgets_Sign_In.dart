import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/domain/Firebase/UserFirebase.dart';
import 'package:mi_hospital/appConfig/domain/sqlite/Sqlite.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/log_in/presentation/log_in.dart';
import 'package:mi_hospital/sections/Menu_main/presentation/main_menu.dart';
import 'package:mi_hospital/sections/log_in/presentation/widgets_Log_In.dart';

class WidgetsSignIn {
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();

  Widget iniciarSesionTextLogIn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: const Text(
          "Iniciar Sesión",
          style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Container formTextLogIn(String text, controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Colors.white,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: text == "Contraseña",
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: text,
          errorStyle: TextStyle(color: Colors.red),
          prefixIcon: Icon(
            text == "Correo" ? Icons.email : Icons.lock,
            color: Color(0xFF48CAE4),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Por favor ingrese $text';
          }
          if (text == "Correo" && !isValidEmail(value)) {
            return 'Ingrese un correo válido';
          }
          return null;
        },
      ),
    );
  }

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }

  Padding containerLogin(context) {
    final _formKey = GlobalKey<FormState>();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 193, 223, 244),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                WidgetsSignIn().formTextLogIn("Correo", controllerEmail),
                SizedBox(height: 20),
                WidgetsSignIn().formTextLogIn("Contraseña", controllerPassword),
                SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => LogInScreen()),
                        );
                      },
                      child: Text(
                        "Regístrate",
                        style: TextStyle(
                          color: Color(0xFF48CAE4),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        "¿Olvidaste tu contraseña?",
                        style: TextStyle(
                          color: Color(0xFF48CAE4),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async { 
                    if (_formKey.currentState!.validate()) {
                      if (await Userfirebase().loginUser(
                        controllerEmail.value.text,
                        controllerPassword.value.text,
                        context,
                      )) {
                        Map<String, dynamic>? datos = await Userfirebase().getUserByEmail(controllerEmail.value.text);
                        if(datos != null) {
                          DatabaseHelper().initDB();
                          DatabaseHelper().insertUserSQlite(
                            datos['name'] as String, 
                            datos['email'] as String, 
                            datos['codigo'] as String
                          );
                          await Future.delayed(Duration(seconds: 2));
                          await GetData().rechargeData();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MainMenuScreen(),
                            ),
                          );
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF48CAE4),
                    padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    "Iniciar Sesión",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool verificationFieldsVoid() {
    return controllerEmail.text.isEmpty || controllerPassword.text.isEmpty;
  }
}
