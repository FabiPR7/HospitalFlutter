import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/appConfig/domain/sqlite/Sqlite.dart';


class StaffFirebase {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();

   Future<List<Map>> getUsersWithSamePrefix(codigo) async {
    if (codigo == null || codigo!.length < 4) {
      return [];
    }
    final prefix = codigo!.substring(0, 4); 
    final snapshot = await _databaseReference
        .child("users")
        .orderByChild("codigo")
        .startAt(prefix)
        .endAt('$prefix\uf8ff') 
        .once();

    List<Map> results = [];
    if (snapshot.snapshot.exists) {
      final data = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
      data.forEach((key, value) {
        results.add({"id": key, ...Map<String, dynamic>.from(value)});
      });
    }
    return results;
  }
}

