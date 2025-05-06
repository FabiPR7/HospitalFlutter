import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/sections/Tasks/entitites/Task.dart';
 // Asegúrate de importar tu clase Task

class Tasksfirebase {
  Future<List<Task>> getTasks(String codePrefix) async {
    final databaseRef = FirebaseDatabase.instance.ref().child('tasks');
    final DataSnapshot snapshot = await databaseRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      final Map<String, dynamic> tasks = Map<String, dynamic>.from(snapshot.value as Map);

      // Filtrar tareas según codePrefix
      final filteredTasks = tasks.entries.where((entry) {
        final task = Map<String, dynamic>.from(entry.value);
        return task['createdBy'] != null &&
               task['createdBy'].toString().startsWith(codePrefix);
      }).toList();

      // Ordenar por timestamp (más antiguo primero)
      filteredTasks.sort((a, b) {
        final aTime = DateTime.tryParse(a.value['timestamp'] ?? '') ?? DateTime(1900);
        final bTime = DateTime.tryParse(b.value['timestamp'] ?? '') ?? DateTime(1900);
        return aTime.compareTo(bTime);
      });

      // Convertir a lista de objetos Task
      return filteredTasks.map((entry) {
        return Task.fromMap(entry.key, Map<String, dynamic>.from(entry.value));
      }).toList();
    }

    return [];
  }
}
