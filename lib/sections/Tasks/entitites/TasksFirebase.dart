import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/sections/Tasks/entitites/Task.dart';
import 'package:mi_hospital/main.dart';

class Tasksfirebase {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<List<Task>> getTasks(String codePrefix, {bool filterByPatient = false}) async {
    final databaseRef = FirebaseDatabase.instance.ref().child('tasks');
    final DataSnapshot snapshot = await databaseRef.get();

    if (snapshot.exists && snapshot.value is Map) {
      final Map<String, dynamic> tasks = Map<String, dynamic>.from(snapshot.value as Map);
      final userHospitalCode = GetData().getHospitalCode();
      
      final filteredTasks = tasks.entries.where((entry) {
        final task = Map<String, dynamic>.from(entry.value);
        final patientDni = task['patientDni'] as String;
        
        bool isFromCurrentHospital = false;
        for (var patient in GetData().getPatients()) {
          if (patient['dni'] == patientDni) {
            isFromCurrentHospital = true;
            break;
          }
        }
        
        if (filterByPatient) {
          return isFromCurrentHospital && patientDni == codePrefix;
        }
        
        return isFromCurrentHospital;
      }).toList();

      filteredTasks.sort((a, b) {
        final aTime = DateTime.tryParse(a.value['timestamp'] ?? '') ?? DateTime(1900);
        final bTime = DateTime.tryParse(b.value['timestamp'] ?? '') ?? DateTime(1900);
        return aTime.compareTo(bTime);
      });

      return filteredTasks.map((entry) {
        return Task.fromMap(entry.key, Map<String, dynamic>.from(entry.value));
      }).toList();
    }

    return [];
  }

  Future<void> add_task({
    required String description,
    required String patientDni,
    String? assignedTo,
    required String createdBy,
  }) async {
    try {
      final newTaskRef = _dbRef.child('tasks').push();
      final timestamp = DateTime.now().toIso8601String();

      final taskData = {
        'description': description,
        'patientDni': patientDni,
        'createdBy': createdBy,
        'timestamp': timestamp,
      };

      if (assignedTo != null) {
        taskData['assignedTo'] = assignedTo;
      }

      await newTaskRef.set(taskData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> assignTaskToMe(String taskId) async {
    try {
      final userCode = GetData().getUserLogin()['codigo'];
      await _dbRef.child('tasks').child(taskId).update({
        'assignedTo': userCode
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> markTaskAsDone(String taskId) async {
    try {
      await _dbRef.child('tasks').child(taskId).update({
        'isDone': true,
        'completedAt': ServerValue.timestamp,
      });
    } catch (e) {
      throw Exception('Error al marcar la tarea como realizada: $e');
    }
  }

  Future<void> deleteTask(String taskId) async {
    try {
      await _dbRef.child('tasks').child(taskId).remove();
    } catch (e) {
      throw Exception('Error al eliminar la tarea: $e');
    }
  }
}
