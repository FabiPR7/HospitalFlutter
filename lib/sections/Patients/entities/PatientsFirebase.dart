import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/Notifications/entities/Notification.dart';
import 'package:mi_hospital/sections/Notifications/infrastructure/NotificationFirebase.dart';
import 'package:mi_hospital/sections/Notifications/presentation/notification_overlay.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'package:flutter/material.dart';

class PatientsFirebase {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final NotificationFirebase _notificationFirebase = NotificationFirebase();

  Future<List<Map<String, dynamic>>> getPatients(String codigoHospital) async {
    final snapshot = await _dbRef.child('patients').once();
    final tasksSnapshot = await _dbRef.child('tasks').once();
    List<Map<String, dynamic>> pacientesFiltrados = [];
    
    if (snapshot.snapshot.value != null) {
      final Map<dynamic, dynamic> pacientes = snapshot.snapshot.value as Map<dynamic, dynamic>;
      final Map<dynamic, dynamic> tasks = tasksSnapshot.snapshot.value as Map<dynamic, dynamic>? ?? {};
      
      pacientes.forEach((key, value) {
        if (value['code'] == codigoHospital && value['state'] == 'Baja') {
          int taskCount = 0;
          if (tasks.isNotEmpty) {
            tasks.forEach((taskKey, taskValue) {
              if (taskValue['patientDni'] == value['dni']) {
                taskCount++;
              }
            });
          }

          pacientesFiltrados.add({
            "id": key,
            "name": value['name'],
            "dni": value["dni"],
            "img": value['img'],
            "task": taskCount,
            "roomName": value['roomName'] ?? 'Sin asignar',
            "admissionDate": value['admissionDate'] ?? 'Desconocido',
            "address": value['address'] ?? '',
            "phone": value['phone'] ?? '',
            "description": value['description'] ?? '',
          });
        }
      });
    }

    return pacientesFiltrados;
  }

  Future<void> addPatient(Map<String, dynamic> paciente, {BuildContext? context}) async {
    try {
      final snapshot = await _dbRef.child('patients').orderByChild('dni').equalTo(paciente['dni']).once();
      
      if (snapshot.snapshot.exists) {
        throw Exception('Ya existe un paciente registrado con este DNI');
      }

      final newPatientRef = _dbRef.child('patients').push();
      await newPatientRef.set({
        ...paciente,
        'code': GetData().getHospitalCode(),
        'state': 'Baja',
      });

      final staffList = GetData().getStaffList() as List;
      final activeStaff = staffList.where((staff) => 
        staff['state'] == true && 
        staff['hospitalCode'] == GetData().getHospitalCode()
      ).toList();
      
      for (var staff in activeStaff) {
        final staffCode = staff['codigo'] as String;
        
        if (staffCode != GetData().getUserLogin()["codigo"]) {
          final notification = AppNotification(
            id: DateTime.now().millisecondsSinceEpoch.toString() + '_$staffCode',
            title: 'Nuevo paciente ingresado',
            message: '${GetData().getUserLogin()["nombre"]} ha ingresado un nuevo paciente: ${paciente["name"]} en la habitación ${paciente["roomName"]}',
            type: 'patient',
            senderCode: GetData().getUserLogin()["codigo"],
            receiverCode: staffCode,
            timestamp: DateTime.now(),
          );

          await _notificationFirebase.createNotification(notification);
        }
      }

      if (context != null) {
        NotificationOverlay().show(
          context: context,
          title: 'Paciente ingresado',
          message: 'Has ingresado un nuevo paciente: ${paciente["name"]} en la habitación ${paciente["roomName"]}',
          type: 'patient',
          onTap: () {
            
          },
        );
      }
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: TextStyle(color: ThemeController.to.getTextColor()),
            ),
            backgroundColor: ThemeController.to.getErrorRed(),
          ),
        );
      }
      throw e;
    }
  }
}
