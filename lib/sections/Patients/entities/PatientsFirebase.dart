import 'package:firebase_database/firebase_database.dart';

class PatientsFirebase {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<List<Map<String, dynamic>>> getPatients(String codigoHospital) async {
    final snapshot = await _dbRef.child('patients').once();
    List<Map<String, dynamic>> pacientesFiltrados = [];
    if (snapshot.snapshot.value != null) {
      final Map<dynamic, dynamic> pacientes = snapshot.snapshot.value as Map<dynamic, dynamic>;
      pacientes.forEach((key, value) {
        if (value['code'] == codigoHospital && value['state'] == 'Baja') {
          pacientesFiltrados.add({
            "id": key,
            "name": value['name'],
            "dni" : value["dni"],
            "img": value['img'],
            "task": value['task'] ?? [],
            "roomName": value['roomName'] ?? 'Sin asignar',
            "admissionDate": value['admissionDate'] ?? 'Desconocido',
          });
        }
      });
    }

    return pacientesFiltrados;
  }
}
