import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/main.dart';

class ProfileFirebase {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<void> updateUserProfile(String codigo, Map<String, dynamic> newData) async {
    try {
      final snapshot = await _dbRef.child('users').orderByChild('codigo').equalTo(codigo).once();
      
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        final userId = data.keys.first;
        
        await _dbRef.child('users/$userId').update({
          'correo': newData['correo'],
          'telefono': newData['telefono'],
        });

        await GetData().updateUserData(newData);
      } else {
        throw Exception('Usuario no encontrado');
      }
    } catch (e) {
      print('Error al actualizar el perfil: $e');
      throw Exception('Error al actualizar el perfil: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String codigo) async {
    try {
      final snapshot = await _dbRef.child('users').orderByChild('codigo').equalTo(codigo).once();
      if (snapshot.snapshot.exists) {
        final data = snapshot.snapshot.value as Map<dynamic, dynamic>;
        return Map<String, dynamic>.from(data.values.first);
      }
      return null;
    } catch (e) {
      print('Error al obtener el perfil: $e');
      return null;
    }
  }
} 