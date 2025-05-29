import 'package:firebase_database/firebase_database.dart';

class HospitalFirebase {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  
  Future<String?> obtenerNombrePorCodigo(String codigo) async {
  try {
    final snapshot = await _dbRef
        .child('hospitals')
        .orderByChild('code')
        .equalTo(codigo)
        .once();

    if (snapshot.snapshot.exists) {
      final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
      final hospitalData = data.values.first; // Obtiene el primer hospital
      return hospitalData['name']?.toString(); // Conversión segura a String
    }
    return null; // Mejor que devolver "No name"
  } catch (e) {
    print('Error buscando hospital: $e');
    return null;
  }
}

}
