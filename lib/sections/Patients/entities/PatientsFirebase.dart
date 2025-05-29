import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/main.dart';

class PatientsFirebase {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

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

  Future<void> addPatient(Map<String, dynamic> paciente) async {
    try {
      final newPatientRef = _dbRef.child('patients').push();
      await newPatientRef.set({
        ...paciente,
        'code': GetData().getHospitalCode(),
        'state': 'Baja',
      });
    } catch (e) {
      throw e;
    }
  }
}
