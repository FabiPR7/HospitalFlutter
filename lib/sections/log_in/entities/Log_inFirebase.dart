import 'package:firebase_database/firebase_database.dart';

class LogInFirebase {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

  // Verifica si el código ya está en uso por algún usuario
  Future<bool> isCodeInUse(String code) async {
    try {
      final snapshot = await _databaseReference
          .child('users')
          .orderByChild('codigo')
          .equalTo(code)
          .once();
      
      return snapshot.snapshot.value != null;
    } catch (e) {
      return true; 
    }
  }

  Future<String?> getHospitalName(String code) async {
    try {
      final prefix = code.split('-')[0];
      
      final snapshot = await _databaseReference
          .child('hospitals')
          .child(prefix)
          .once();

      if (snapshot.snapshot.value != null) {
        final hospitalData = snapshot.snapshot.value as Map<dynamic, dynamic>;
        return hospitalData['name'] as String?;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> isCodeValid(String code) async {
    try {
      final prefijosSnapshot = await _databaseReference
          .child('codes')
          .once();

      if (prefijosSnapshot.snapshot.value == null) {
        return false;
      }

      final prefijos = prefijosSnapshot.snapshot.value as Map<dynamic, dynamic>;
      
      for (var prefijo in prefijos.entries) {
        final codigos = prefijo.value as Map<dynamic, dynamic>;
        
        for (var codigo in codigos.values) {
          if (codigo is Map && codigo['code'] == code) {
            return true;
          }
        }
      }

      return false;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>> validateCode(String code) async {
    bool isInUse = await isCodeInUse(code);
    if (isInUse) {
      return {
        'isValid': false,
        'hospitalName': null,
        'message': 'El código ya está en uso'
      };
    }

    bool isValid = await isCodeValid(code);
    if (!isValid) {
      return {
        'isValid': false,
        'hospitalName': null,
        'message': 'El código no es válido'
      };
    }

    String? hospitalName = await getHospitalName(code);
    
    return {
      'isValid': true,
      'hospitalName': hospitalName,
      'message': 'Código válido'
    };
  }
} 