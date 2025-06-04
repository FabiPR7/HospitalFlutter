import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/sections/Tasks/entitites/Task.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/Notifications/entities/Notification.dart';
import 'package:mi_hospital/sections/Notifications/infrastructure/NotificationFirebase.dart';
import 'package:mi_hospital/sections/Notifications/presentation/notification_overlay.dart';
import 'package:flutter/material.dart';
import 'package:mi_hospital/sections/Tasks/entitites/GetDataTask.dart';

class Tasksfirebase {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();
  final NotificationFirebase _notificationFirebase = NotificationFirebase();

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
    BuildContext? context,
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
        
        final staffList = GetData().getStaffList() as List;
        final assignedStaff = staffList.firstWhere(
          (staff) => staff['codigo'] == assignedTo,
          orElse: () => {'nombre': 'Personal'},
        );

        final notification = AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Nueva tarea asignada',
          message: '${GetData().getUserLogin()["nombre"]} te ha asignado una tarea para el paciente ${GetDataTask().convertDnitoNamePatient(patientDni)}: ${description.length > 50 ? description.substring(0, 50) + "..." : description}',
          type: 'task',
          senderCode: createdBy,
          receiverCode: assignedTo,
          timestamp: DateTime.now(),
        );

        await _notificationFirebase.createNotification(notification);

        if (context != null) {
          NotificationOverlay().show(
            context: context,
            title: 'Nueva tarea asignada',
            message: '${GetData().getUserLogin()["nombre"]} te ha asignado una tarea para el paciente ${GetDataTask().convertDnitoNamePatient(patientDni)}: ${description.length > 50 ? description.substring(0, 50) + "..." : description}',
            type: 'task',
            onTap: () {
              // TODO: Navegar a la vista de tareas
            },
          );
        }
      } else {
        final staffList = GetData().getStaffList() as List;
        final activeStaff = staffList.where((staff) => staff['state'] == true).toList();
        
        for (var staff in activeStaff) {
          final staffCode = staff['codigo'] as String;
          
          if (staffCode != createdBy) {
            final notification = AppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString() + '_$staffCode',
              title: 'Nueva tarea disponible',
              message: 'Hay una nueva tarea sin asignar: ${description.length > 50 ? description.substring(0, 50) + "..." : description}',
              type: 'task_unassigned',
              senderCode: createdBy,
              receiverCode: staffCode,
              timestamp: DateTime.now(),
            );

            await _notificationFirebase.createNotification(notification);
          }
        }

        if (context != null) {
          NotificationOverlay().show(
            context: context,
            title: 'Tarea creada',
            message: 'Has creado una nueva tarea sin asignar',
            type: 'task_unassigned',
            onTap: () {
              // TODO: Navegar a la vista de tareas
            },
          );
        }
      }

      await newTaskRef.set(taskData);
    } catch (e) {
      throw e;
    }
  }

  Future<void> assignTaskToMe(String taskId, {BuildContext? context}) async {
    try {
      final userCode = GetData().getUserLogin()['codigo'];
      await _dbRef.child('tasks').child(taskId).update({
        'assignedTo': userCode
      });

      final taskSnapshot = await _dbRef.child('tasks').child(taskId).get();
      if (taskSnapshot.exists) {
        final taskData = Map<String, dynamic>.from(taskSnapshot.value as Map);
        final createdBy = taskData['createdBy'] as String;
        
        final notification = AppNotification(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          title: 'Tarea auto-asignada',
          message: '${GetData().getUserLogin()["nombre"]} se ha auto-asignado una tarea',
          type: 'task',
          senderCode: userCode,
          receiverCode: createdBy,
          timestamp: DateTime.now(),
        );

        await _notificationFirebase.createNotification(notification);

        if (context != null) {
          NotificationOverlay().show(
            context: context,
            title: 'Tarea auto-asignada',
            message: 'Te has auto-asignado una tarea',
            type: 'task',
            onTap: () {
             
            },
          );
        }
      }
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
