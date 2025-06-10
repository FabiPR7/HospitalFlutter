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
                      backgroundColor: ThemeController.to.getButtonBlue(),
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
                backgroundColor: ThemeController.to.getButtonBlue(),
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
                  Icon(Icons.task_alt, color: ThemeController.to.getButtonBlue()),
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
        IconData timeIcon;
        String timeStatus;
        if (difference.inHours >= 2) {
          backgroundColor = ThemeController.to.getTaskCardColor(2);
          timeIcon = Icons.warning_amber_rounded;
          timeStatus = 'Tardía';
        } else if (difference.inHours >= 1) {
          backgroundColor = ThemeController.to.getTaskCardColor(1);
          timeIcon = Icons.access_time;
          timeStatus = 'Próxima';
        } else {
          backgroundColor = ThemeController.to.getTaskCardColor(0);
          timeIcon = Icons.access_time;
          timeStatus = 'Reciente';
        }
        return Card(
          elevation: 3,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  backgroundColor.withOpacity(0.6),
                  backgroundColor.withOpacity(0.7),
                ],
              ),
              border: Border.all(
                color: backgroundColor.withOpacity(0.7),
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () => _showTaskDetailsDialog(context, task),
              borderRadius: BorderRadius.circular(15),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: backgroundColor.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.task_alt,
                            color: backgroundColor.withOpacity(0.9),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            task.description,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: ThemeController.to.getTextColor(),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ThemeController.to.getBackgroundBlue().withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          _buildTaskInfoRow(
                            Icons.person_outline,
                            'Paciente:',
                            GetDataTask().convertDnitoNamePatient(task.patientDni),
                          ),
                          const SizedBox(height: 8),
                          _buildTaskInfoRow(
                            Icons.person,
                            'Creado por:',
                            GetDataTask().convertCodetoNameStaff(task.createdBy),
                          ),
                          const SizedBox(height: 8),
                          _buildTaskInfoRow(
                            Icons.assignment_ind,
                            'Asignado a:',
                            task.assignedTo == null ? "Sin asignar" : GetDataTask().convertCodetoNameStaff(task.assignedTo.toString()),
                          ),
                          const SizedBox(height: 8),
                          _buildTaskInfoRow(
                            Icons.access_time,
                            'Fecha/Hora:',
                            formattedDate,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (difference.inHours >= 1) ...[
                                Icon(
                                  timeIcon,
                                  size: 16,
                                  color: ThemeController.to.getButtonBlue(),
                                ),
                                const SizedBox(width: 4),
                              ],
                              Text(
                                timeStatus,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: ThemeController.to.getButtonBlue(),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!task.isDone && (task.assignedTo.toString().isEmpty || task.assignedTo == null))
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: ElevatedButton(
                          onPressed: () => _showConfirmationDialog(context, task),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: ThemeController.to.getButtonBlue(),
                            minimumSize: const Size(double.infinity, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Asignarme',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTaskInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: ThemeController.to.getTextColor().withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: ThemeController.to.getTextColor().withOpacity(0.7),
          ),
        ),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: ThemeController.to.getTextColor(),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return listCards(context);
  }
}
