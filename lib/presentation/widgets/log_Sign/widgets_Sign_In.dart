import 'package:flutter/material.dart';
import 'package:mi_hospital/domain/Firebase/UserFirebase.dart';
import 'package:mi_hospital/domain/sqlite/Sqlite.dart';
import 'package:mi_hospital/presentation/screen/log_in.dart';
import 'package:mi_hospital/presentation/screen/main_menu.dart';
import 'package:mi_hospital/presentation/widgets/log_Sign/widgets_Log_In.dart';

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
        ),
      ),
    );
  }

  Padding containerLogin(context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: const Color.fromARGB(255, 193, 223, 244),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              WidgetsSignIn().formTextLogIn("Correo", controllerEmail),
              SizedBox(height: 20),
              WidgetsSignIn().formTextLogIn("Contraseña", controllerPassword),
              SizedBox(height: 10),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LogInScreen()),
                      );
                    },
                    child: Text("Regístrate"),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text("¿Olvidaste tu contraseña?"),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () async { 
                  if (!verificationFieldsVoid()) {
                    if (await Userfirebase().loginUser(
                      controllerEmail.value.text,
                      controllerPassword.value.text,
                      context,
                    )) {
                       Map<String, dynamic>? datos =  await Userfirebase().getUserByEmail(controllerEmail.value.text);
                       if(datos != null) {
                      DatabaseHelper().initDB();
                      DatabaseHelper().insertUserSQlite(datos?['name'] as String, datos?['email'] as String, datos?['codigo'] as String);
                      await Future.delayed(Duration(seconds: 2));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainMenuScreen(),
                        ),
                      );
                    }
                    }
                  } else {
                    WidgetsLogIn().getToastMessage(
                      context,
                      "Rellena todos los campos",
                    );
                  }
                },
                child: Text("Aceptar"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool verificationFieldsVoid() {
    return controllerEmail.text.isEmpty || controllerPassword.text.isEmpty;
  }
}
