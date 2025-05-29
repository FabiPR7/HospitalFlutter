import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mi_hospital/sections/Tasks/entitites/GetDataTask.dart';
import 'package:mi_hospital/sections/Tasks/entitites/Task.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/Tasks/entitites/TasksFirebase.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';

class WidgetsTask extends StatefulWidget {
  final List<Task> tasks;
  final VoidCallback onTaskAssigned;
  
  const WidgetsTask({
    Key? key, 
    required this.tasks,
    required this.onTaskAssigned,
  }) : super(key: key);

  @override
  State<WidgetsTask> createState() => _WidgetsTaskState();
}

class _WidgetsTaskState extends State<WidgetsTask> {
  final Tasksfirebase _tasksFirebase = Tasksfirebase();

  Future<void> _showConfirmationDialog(BuildContext context, Task task) async {
    final BuildContext dialogContext = context;
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.medical_services, color: Colors.blue[700]),
              const SizedBox(width: 10),
              const Text(
                'Confirmar Asignación',
                style: TextStyle(
                  color: Color(0xFF2641F3),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Text(
              '¿Estás seguro que deseas asignarte esta tarea?',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF2641F3),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Cancelar',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await _tasksFirebase.assignTaskToMe(task.id);
                  if (!mounted) return;
                  widget.onTaskAssigned();
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: const Text('Tarea asignada exitosamente'),
                      backgroundColor: ThemeHospital.getButtonBlue(),
                    ),
                  );
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Error al asignar tarea: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHospital.getButtonBlue(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Confirmar',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showTaskDetailsDialog(BuildContext context, Task task) {
    final String currentUserCode = GetData().getUserLogin()["codigo"];
    final bool isTaskCreator = task.createdBy == currentUserCode;

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        String formattedDate = DateFormat('dd-MM-yy HH:mm').format(task.timestamp);
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.task_alt, color: ThemeHospital.getButtonBlue()),
                  const SizedBox(width: 10),
                  const Text(
                    'Detalles de la Tarea',
                    style: TextStyle(
                      color: Color(0xFF2641F3),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.grey),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInfoRow('Descripción:', task.description),
                      const SizedBox(height: 10),
                      _buildInfoRow('Paciente:', GetDataTask().convertDnitoNamePatient(task.patientDni)),
                      _buildInfoRow('Creado por:', GetDataTask().convertCodetoNameStaff(task.createdBy)),
                      _buildInfoRow('Asignado a:', task.assignedTo == null ? "Sin asignar" : GetDataTask().convertCodetoNameStaff(task.assignedTo.toString())),
                      _buildInfoRow('Fecha/Hora:', formattedDate),
                      if (task.isDone)
                        _buildInfoRow('Estado:', 'Tarea Realizada'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (isTaskCreator)
                  TextButton(
                    onPressed: () async {
                      try {
                        await _tasksFirebase.deleteTask(task.id);
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tarea eliminada exitosamente'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        widget.onTaskAssigned();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al eliminar la tarea: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Eliminar',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                if (!task.isDone && task.assignedTo == GetData().getUserLogin()["codigo"])
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        await _tasksFirebase.markTaskAsDone(task.id);
                        if (!mounted) return;
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Tarea marcada como realizada'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        widget.onTaskAssigned();
                      } catch (e) {
                        if (!mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al marcar la tarea: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Tarea Realizada',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF2641F3),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget listCards(BuildContext context) {
    if (widget.tasks.isEmpty) {
      return const Center(child: Text('No hay tareas disponibles.'));
    }
    return ListView(
      children: widget.tasks.map((task) {
        String formattedDate = DateFormat('dd-MM-yy HH:mm').format(task.timestamp);
        Duration difference = DateTime.now().difference(task.timestamp);
        Color backgroundColor;
        if (difference.inHours >= 2) {
          backgroundColor = ThemeHospital.getTaskCardColor(2);
        } else if (difference.inHours >= 1) {
          backgroundColor = ThemeHospital.getTaskCardColor(1);
        } else {
          backgroundColor = ThemeHospital.getTaskCardColor(0);
        }
        return Card(
          color: backgroundColor,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            onTap: () => _showTaskDetailsDialog(context, task),
            borderRadius: BorderRadius.circular(12),
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
                  Text('Paciente: ${GetDataTask().convertDnitoNamePatient(task.patientDni)}'),
                  Text('Creado por: ${GetDataTask().convertCodetoNameStaff(task.createdBy)}'),
                  Text('Asignado a: ${task.assignedTo == null ? "Sin asignar" : GetDataTask().convertCodetoNameStaff(task.assignedTo.toString())}'),
                  Text('Fecha/Hora: $formattedDate'),
                  if (!task.isDone && (task.assignedTo.toString().isEmpty || task.assignedTo == null))
                    ElevatedButton( 
                      onPressed: () => _showConfirmationDialog(context, task),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: ThemeHospital.getButtonBlue(),
                      ),
                      child: const Text('Asignarme', style: TextStyle(color: Colors.white),),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return listCards(context);
  }
}
