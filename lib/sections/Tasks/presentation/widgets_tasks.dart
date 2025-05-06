import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_hospital/sections/Tasks/entitites/GetDataTask.dart';
import 'package:mi_hospital/sections/tasks/entitites/Task.dart';


class WidgetsTask {
  final List<dynamic> tasks;
  
  const WidgetsTask({required this.tasks});

  Widget listCards(BuildContext context) {
    if (tasks.isEmpty) {
      return const Center(child: Text('No hay tareas disponibles.'));
    }
    return ListView(
      children: tasks.map((task) {
        String formattedDate = DateFormat('dd-MM-yy HH:mm').format(task.timestamp);
        Duration difference = DateTime.now().difference(task.timestamp);
        Color backgroundColor;
        if (difference.inHours >= 2) {
          backgroundColor = Colors.red.shade100;
        } else if (difference.inHours >= 1) {
          backgroundColor = Colors.yellow.shade100;
        } else {
          backgroundColor = Colors.green.shade100;
        }
        return Card(
          color: backgroundColor,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.description,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text('Paciente: ${
                  GetDataTask().convertDnitoNamePatient(task.patientDni)
                }'),
                Text('Creado por: ${GetDataTask().convertCodetoNameStaff(task.createdBy)}'),
                Text('Asignado a: ${task.assignedTo != null ? GetDataTask().convertCodetoNameStaff(task.assignedTo) : "Sin asignar"}'),
                Text('Fecha/Hora: $formattedDate'),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
}
