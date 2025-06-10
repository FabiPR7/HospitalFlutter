import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'package:mi_hospital/sections/Tasks/entitites/TasksFirebase.dart';
import 'package:mi_hospital/sections/Tasks/presentation/widgets_tasks.dart';
import 'package:mi_hospital/sections/Tasks/entitites/Task.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/appConfig/presentation/theme/ThemeController.dart' as theme;

class TasksScreen extends StatefulWidget {
  final String codePrefix;
  final bool showOnlyPatientTasks;
  final bool showAppBar;

  const TasksScreen({
    Key? key,
    required this.codePrefix,
    this.showOnlyPatientTasks = false,
    this.showAppBar = true,
  }) : super(key: key);

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _showAddTaskDialog(BuildContext context) async {
    final TextEditingController descriptionController = TextEditingController();
    String? selectedPatient;
    String? selectedStaff;
    List<Map<String, dynamic>> patients = [];
    List<Map<String, dynamic>> staff = [];
    final patientsList = GetData().getPatients();
    
    patients = (patientsList as List).map((patient) {
      final Map<dynamic, dynamic> patientMap = patient as Map<dynamic, dynamic>;
      return {
        'id': patientMap['dni']?.toString(),
        'name': patientMap['name']?.toString(),
      };
    }).toList();

    final seen = <String>{};
    patients = patients.where((patient) {
      final id = patient['id']?.toString();
      if (id == null || seen.contains(id)) return false;
      seen.add(id);
      return true;
    }).toList();

    staff = (GetData().getStaffList() as List).map((staffMember) {
      final Map<dynamic, dynamic> staffMap = staffMember as Map<dynamic, dynamic>;
      return {
        'id': staffMap['codigo']?.toString(),
        'name': staffMap['name']?.toString(),
        'state': staffMap['state'] ?? false,
      };
    }).where((member) => member['state'] == true).toList();

    final seenStaff = <String>{};
    staff = staff.where((member) {
      final id = member['id']?.toString();
      if (id == null || seenStaff.contains(id)) return false;
      seenStaff.add(id);
      return true;
    }).toList();

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: theme.ThemeController.to.getCardColor(),
          title: Row(
            children: [
              Icon(Icons.medical_services, color: theme.ThemeController.to.getButtonBlue()),
              const SizedBox(width: 10),
              Text(
                'Nueva Tarea',
                style: TextStyle(
                  color: theme.ThemeController.to.getButtonBlue(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (patients.isEmpty)
                  Text(
                    'No hay pacientes disponibles',
                    style: TextStyle(color: theme.ThemeController.to.getTextColor()),
                  )
                else
                  Container(
                    decoration: BoxDecoration(
                      color: theme.ThemeController.to.getSurfaceColor(),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Paciente',
                        labelStyle: TextStyle(color: theme.ThemeController.to.getButtonBlue()),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.ThemeController.to.getButtonBlue()),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.ThemeController.to.getButtonBlue().withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.ThemeController.to.getButtonBlue(), width: 2),
                        ),
                        filled: true,
                        fillColor: theme.ThemeController.to.getCardColor(),
                      ),
                      value: selectedPatient,
                      items: patients.map((patient) {
                        return DropdownMenuItem<String>(
                          value: patient['id'].toString(),
                          child: Text(
                            '${patient['name']} (${patient['id']})',
                            style: TextStyle(color: theme.ThemeController.to.getTextColor()),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => selectedPatient = value);
                      },
                    ),
                  ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: theme.ThemeController.to.getSurfaceColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: descriptionController,
                    style: TextStyle(color: theme.ThemeController.to.getTextColor()),
                    decoration: InputDecoration(
                      labelText: 'Descripción de la tarea',
                      labelStyle: TextStyle(color: theme.ThemeController.to.getButtonBlue()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.ThemeController.to.getButtonBlue()),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.ThemeController.to.getButtonBlue().withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.ThemeController.to.getButtonBlue(), width: 2),
                      ),
                      filled: true,
                      fillColor: theme.ThemeController.to.getCardColor(),
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: theme.ThemeController.to.getSurfaceColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Asignar a (opcional)',
                      labelStyle: TextStyle(color: theme.ThemeController.to.getButtonBlue()),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.ThemeController.to.getButtonBlue()),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.ThemeController.to.getButtonBlue().withOpacity(0.5)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: theme.ThemeController.to.getButtonBlue(), width: 2),
                      ),
                      filled: true,
                      fillColor: theme.ThemeController.to.getCardColor(),
                    ),
                    value: selectedStaff,
                    items: [
                      DropdownMenuItem<String>(
                        value: null,
                        child: Text(
                          'Sin asignar',
                          style: TextStyle(color: theme.ThemeController.to.getTextColor()),
                        ),
                      ),
                      ...staff.map((member) {
                        return DropdownMenuItem<String>(
                          value: member['id'].toString(),
                          child: Text(
                            member['name'].toString(),
                            style: TextStyle(color: theme.ThemeController.to.getTextColor()),
                          ),
                        );
                      }).toList(),
                    ],
                    onChanged: (value) {
                      setState(() => selectedStaff = value);
                    },
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancelar',
                style: TextStyle(
                  color: theme.ThemeController.to.getErrorRed(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (selectedPatient == null || descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Por favor complete todos los campos requeridos',
                        style: TextStyle(color: theme.ThemeController.to.getTextColor()),
                      ),
                      backgroundColor: theme.ThemeController.to.getErrorRed(),
                    ),
                  );
                  return;
                }
                try {
                  await Tasksfirebase().add_task(
                    description: descriptionController.text,
                    patientDni: selectedPatient!,
                    assignedTo: selectedStaff,
                    createdBy: GetData().getUserLogin()["codigo"],
                    context: context,
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    setState(() {});
                    if (selectedStaff != null) {
                      final staffList = GetData().getStaffList() as List;
                      final assignedStaff = staffList.firstWhere(
                        (staff) => staff['codigo'] == selectedStaff,
                        orElse: () => {'name': 'Personal'},
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tarea asignada a ${assignedStaff['name']}',
                            style: TextStyle(color: theme.ThemeController.to.getTextColor()),
                          ),
                          backgroundColor: theme.ThemeController.to.getButtonBlue(),
                          duration: const Duration(seconds: 3),
                          action: SnackBarAction(
                            label: 'Ver',
                            textColor: theme.ThemeController.to.getTextColor(),
                            onPressed: () {
                              // TODO: Navegar a la vista de tareas
                            },
                          ),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tarea creada exitosamente',
                            style: TextStyle(color: theme.ThemeController.to.getTextColor()),
                          ),
                          backgroundColor: theme.ThemeController.to.getButtonBlue(),
                        ),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Error al crear la tarea: $e',
                          style: TextStyle(color: theme.ThemeController.to.getTextColor()),
                        ),
                        backgroundColor: theme.ThemeController.to.getErrorRed(),
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.ThemeController.to.getButtonBlue(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Crear Tarea',
                style: TextStyle(
                  color: theme.ThemeController.to.getTextColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignTaskToMe(String taskId, BuildContext context) async {
    try {
      await Tasksfirebase().assignTaskToMe(taskId, context: context);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Tarea auto-asignada exitosamente'),
            backgroundColor: theme.ThemeController.to.getButtonBlue(),
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Ver',
              textColor: Colors.white,
              onPressed: () {
                // TODO: Navegar a la vista de tareas
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al auto-asignar la tarea: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    GetData().rechargeData();
    
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref().child('tasks').onValue,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              color: theme.ThemeController.to.getButtonBlue(),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: TextStyle(color: theme.ThemeController.to.getTextColor()),
            ),
          );
        }

        final tasks = Tasksfirebase().getTasksFromSnapshot(
          snapshot.data?.snapshot,
          widget.codePrefix,
          filterByPatient: widget.showOnlyPatientTasks,
        );

        Widget buildTaskList(bool showCompleted, bool showOnlyMine) {
          final currentUserCode = GetData().getUserLogin()["codigo"];
          final filteredTasks = tasks.where((task) {
            final isMine = task.assignedTo == currentUserCode;
            final isCompleted = task.isDone;
            
            if (showOnlyMine) {
              return isMine && (showCompleted ? isCompleted : !isCompleted);
            } else {
              return !isCompleted;
            }
          }).toList();

          if (filteredTasks.isEmpty) {
            return Center(
              child: Text(
                showOnlyMine 
                  ? (showCompleted ? 'No tienes tareas realizadas' : 'No tienes tareas pendientes')
                  : 'No hay tareas pendientes',
                style: TextStyle(
                  fontSize: 16,
                  color: theme.ThemeController.to.getGrey(),
                ),
              ),
            );
          }
          
          return WidgetsTask(
            tasks: filteredTasks,
            onTaskAssigned: () {
              setState(() {});
            },
          );
        }

        Widget content = Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: theme.ThemeController.to.getCardColor(),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: theme.ThemeController.to.getButtonBlue(),
                unselectedLabelColor: theme.ThemeController.to.getGrey(),
                indicatorColor: theme.ThemeController.to.getButtonBlue(),
                tabs: const [
                  Tab(
                    icon: Icon(Icons.person),
                    text: 'Mis Pendientes',
                  ),
                  Tab(
                    icon: Icon(Icons.pending_actions),
                    text: 'Pendientes',
                  ),
                  Tab(
                    icon: Icon(Icons.task_alt),
                    text: 'Mis Realizadas',
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  buildTaskList(false, true),
                  buildTaskList(false, false),
                  buildTaskList(true, true),
                ],
              ),
            ),
          ],
        );

        if (widget.showAppBar) {
          return Scaffold(
            backgroundColor: theme.ThemeController.to.getCardColor(),
            appBar: AppBarHospital().getAppBar(),
            floatingActionButton: FloatingActionButton(
              onPressed: () => _showAddTaskDialog(context),
              backgroundColor: theme.ThemeController.to.getButtonBlue(),
              child: Icon(Icons.add, color: theme.ThemeController.to.getTextColor()),
            ),
            body: content,
          );
        }

        return content;
      },
    );
  }
}
