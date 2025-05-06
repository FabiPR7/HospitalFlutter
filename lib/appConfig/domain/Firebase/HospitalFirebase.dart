import 'package:firebase_database/firebase_database.dart';

class HospitalFirebase {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  /// Obtiene el nombre del hospital a partir de su código
  Future<String?> obtenerNombrePorCodigo(String codigo) async {
    try {
      final snapshot = await _dbRef.child('hospitales/$codigo').get();

      if (snapshot.exists) {
        final data = snapshot.value as Map<dynamic, dynamic>;
        return data['nombre'] as String?;
      } else {
        return null; // No encontrado
      }
    } catch (e) {
      print('Error al leer hospital: $e');
      return null;
    }
  }
}
