import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/domain/Firebase/UserFirebase.dart';
import 'package:mi_hospital/appConfig/domain/sqlite/Sqlite.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/log_in/presentation/log_in.dart';
import 'package:mi_hospital/sections/Menu_main/presentation/main_menu.dart';
import 'package:mi_hospital/sections/log_in/presentation/widgets_Log_In.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';

class WidgetsSignIn {
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();

  Widget iniciarSesionTextLogIn() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ThemeController.to.getButtonBlue(),
            ThemeController.to.getLightBlue(),
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
                Icons.medical_services,
                size: 40,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Iniciar Sesión",
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
              "Bienvenido de nuevo",
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
        obscureText: text == "Contraseña",
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          labelText: text,
          labelStyle: TextStyle(
            color: ThemeController.to.getButtonBlue().withOpacity(0.7),
            fontSize: 16,
          ),
          errorStyle: const TextStyle(color: Colors.red),
          prefixIcon: Icon(
            text == "Correo" ? Icons.email : Icons.lock,
            color: ThemeController.to.getButtonBlue(),
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
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              ThemeController.to.getBackgroundBlue().withOpacity(0.1),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                formTextLogIn("Correo", controllerEmail),
                const SizedBox(height: 16),
                formTextLogIn("Contraseña", controllerPassword),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      bool result = await Userfirebase().loginUser(
                        controllerEmail.text,
                        controllerPassword.text,
                        context,
                      );
                      if (result) {
                        Map<String, dynamic>? datos = await Userfirebase().getUserByEmail(controllerEmail.text);
                        if (datos != null) {
                          await DatabaseHelper().initDB();
                          await DatabaseHelper().insertUserSQlite(
                            datos['name'] ?? '',
                            datos['email'] ?? '',
                            datos['codigo'] ?? ''
                          );
                          await Future.delayed(const Duration(seconds: 2));
                          await GetData().rechargeData();
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainMenuScreen(),
                              ),
                            );
                          }
                        }
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: ThemeController.to.getButtonBlue(),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Iniciar Sesión",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LogInScreen(),
                      ),
                    );
                  },
                  child: Text(
                    "¿No tienes una cuenta? Regístrate",
                    style: TextStyle(
                      color: ThemeController.to.getButtonBlue(),
                      fontSize: 14,
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
