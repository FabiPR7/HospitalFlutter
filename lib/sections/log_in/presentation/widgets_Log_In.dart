import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/domain/Firebase/UserFirebase.dart';
import 'package:mi_hospital/appConfig/domain/entities/User.dart';
import 'package:mi_hospital/sections/Log_in/entities/Log_inFirebase.dart';
import 'package:mi_hospital/appConfig/domain/sqlite/Sqlite.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';

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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        backgroundColor: ThemeHospital.getButtonBlue(),
      ),
    );
  }

  Widget registrarTextLogIn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeHospital.getButtonBlue(),
            ThemeHospital.getLightBlue(),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.person_add,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Regístrate",
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Crea tu cuenta",
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.8),
                shadows: [
                  Shadow(
                    offset: const Offset(1, 1),
                    blurRadius: 3,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container formTextLogIn(String text, controller) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: text == "Contraseña" || text == "Confirmar Contraseña",
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelText: text,
          labelStyle: TextStyle(
            color: ThemeHospital.getButtonBlue().withOpacity(0.7),
            fontSize: 16,
          ),
          errorStyle: const TextStyle(color: Colors.red),
          prefixIcon: Icon(
            text == "Nombre Completo" ? Icons.person :
            text == "Correo" ? Icons.email :
            text == "Contraseña" || text == "Confirmar Contraseña" ? Icons.lock :
            Icons.vpn_key,
            color: ThemeHospital.getButtonBlue(),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
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
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              ThemeHospital.getBackgroundBlue().withOpacity(0.1),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                WidgetsLogIn().formTextLogIn("Nombre Completo", controllerName),
                const SizedBox(height: 20),
                WidgetsLogIn().formTextLogIn("Correo", controllerEmail),
                const SizedBox(height: 10),
                WidgetsLogIn().formTextLogIn("Contraseña", controllerPassword),
                const SizedBox(height: 20),
                WidgetsLogIn().formTextLogIn(
                  "Confirmar Contraseña",
                  controllerConfirmPassword,
                ),
                const SizedBox(height: 20),
                WidgetsLogIn().formTextLogIn(
                  "Código de Verificación",
                  controllerCode,
                ),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        ThemeHospital.getButtonBlue(),
                        ThemeHospital.getLightBlue(),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: ThemeHospital.getButtonBlue().withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
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
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Registrarse",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
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
