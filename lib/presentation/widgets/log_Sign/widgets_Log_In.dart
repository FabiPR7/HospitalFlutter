import 'package:flutter/material.dart';
import 'package:mi_hospital/domain/Firebase/UserFirebase.dart';
import 'package:mi_hospital/domain/entities/User.dart';

class WidgetsLogIn {
  final controllerName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerConfirmPassword = TextEditingController();
  final controllerCode = TextEditingController();

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> getToastMessage(
    context,
    text,
  ) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: Duration(seconds: 3), // Duración del mensaje
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
                  UserEntity user = UserEntity(
                    name: controllerName.value.text,
                    email: controllerEmail.value.text,
                    code: controllerCode.value.text,
                  );
                  if (verificationVoid(
                    user.name,
                    user.email,
                    controllerPassword.value.text,
                    controllerConfirmPassword.value.text,
                    user.code,
                  )) {
                    if (isValidEmail(user.email)) {
                      if (passwordMatch(
                        controllerPassword.value.text,
                        controllerConfirmPassword.value.text,
                      )) {
                        if (controllerPassword.value.text.length >= 8) {
                          if (await Userfirebase().registerUser(
                            user,
                            controllerPassword.value.text,
                            context,
                          )) {
                            getToastMessage(
                              context,
                              "Usuario registrado correctamente",
                            );
                            controllerName.clear();
                            controllerEmail.clear();
                            controllerPassword.clear();
                            controllerConfirmPassword.clear();
                            controllerCode.clear();
                          } else {
                            getToastMessage(context, "Error al registrar");
                          }
                        } else {
                          getToastMessage(
                            context,
                            "La contraseña debe tener al menos 8 caracteres",
                          );
                        }
                      } else {
                        getToastMessage(
                          context,
                          "Las contraseñas no coinciden",
                        );
                      }
                    } else {
                      getToastMessage(context, "Ingresa un correo válido");
                    }
                  } else {
                    getToastMessage(context, "Llene todos los campos");
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

  bool verificationVoid(
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
    //+
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$'); //+
    return emailRegExp.hasMatch(email); //+
  } //+

  // {"conversationId":"56cad181-7ccf-4851-b829-0b54c448bc29","source":"instruct"}
}
