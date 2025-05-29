import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/domain/Firebase/UserFirebase.dart';
import 'package:mi_hospital/appConfig/domain/entities/User.dart';
import 'package:mi_hospital/sections/Log_in/entities/Log_inFirebase.dart';
import 'package:mi_hospital/appConfig/domain/sqlite/Sqlite.dart';

class WidgetsLogIn {
  final controllerName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerConfirmPassword = TextEditingController();
  final controllerCode = TextEditingController();
  final LogInFirebase _logInFirebase = LogInFirebase();

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> getToastMessage(
    context,
    text,
  ) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: 3),
      ),
    );
  }

  Widget registrarTextLogIn() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: const Text(
          "Regístrate",
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
        obscureText: text == "Contraseña" || text == "Confirmar Contraseña",
        decoration: InputDecoration(
          border: OutlineInputBorder(),
          labelText: text,
          errorStyle: TextStyle(color: Colors.red),
          prefixIcon: Icon(
            text == "Nombre Completo" ? Icons.person :
            text == "Correo" ? Icons.email :
            text == "Contraseña" || text == "Confirmar Contraseña" ? Icons.lock :
            Icons.vpn_key,
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
          if ((text == "Contraseña" || text == "Confirmar Contraseña") && value.length < 8) {
            return 'La contraseña debe tener al menos 8 caracteres';
          }
          return null;
        },
      ),
    );
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
                WidgetsLogIn().formTextLogIn("Nombre Completo", controllerName),
                SizedBox(height: 20),
                WidgetsLogIn().formTextLogIn("Correo", controllerEmail),
                SizedBox(height: 10),
                WidgetsLogIn().formTextLogIn("Contraseña", controllerPassword),
                SizedBox(height: 20),
                WidgetsLogIn().formTextLogIn(
                  "Confirmar Contraseña",
                  controllerConfirmPassword,
                ),
                SizedBox(height: 20),
                WidgetsLogIn().formTextLogIn(
                  "Código de Verificación",
                  controllerCode,
                ),
                SizedBox(height: 20),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (passwordMatch(
                        controllerPassword.value.text,
                        controllerConfirmPassword.value.text,
                      )) {
                        var validationResult = await _logInFirebase.validateCode(controllerCode.value.text);
                        
                        if (!validationResult['isValid']) {
                          getToastMessage(
                            context,
                            validationResult['message'],
                          );
                          return;
                        }

                        UserEntity user = UserEntity(
                          name: controllerName.value.text,
                          email: controllerEmail.value.text,
                          code: controllerCode.value.text,
                        );
                        
                        if (await Userfirebase().registerUser(
                          user,
                          controllerPassword.value.text,
                          context,
                        )) {
                          Navigator.pop(context);
                        }
                      } else {
                        getToastMessage(
                          context,
                          "Las contraseñas no coinciden",
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48CAE4),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text(
                    "Registrarse",
                    style: TextStyle(
                      fontSize: 18,
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

  bool verificationFieldsVoid(
    String name,
    String email,
    String pwd,
    String pwd2,
    String codigo,
  ) {
    if (name.isEmpty ||
        email.isEmpty ||
        pwd.isEmpty ||
        pwd2.isEmpty ||
        codigo.isEmpty) {
      return false;
    }
    return true;
  }

  bool passwordMatch(String pwd, String pwd2) {
    if (pwd != pwd2) {
      return false;
    }
    return true;
  }

  bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegExp.hasMatch(email);
  }
}
