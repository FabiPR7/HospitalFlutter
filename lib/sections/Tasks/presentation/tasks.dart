import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'package:mi_hospital/sections/Tasks/entitites/TasksFirebase.dart';
import 'package:mi_hospital/sections/Tasks/presentation/widgets_tasks.dart';
import 'package:mi_hospital/sections/Tasks/entitites/Task.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/main.dart';

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

    staff = (GetData().getStaffList() as List).map((staffMember) {
      final Map<dynamic, dynamic> staffMap = staffMember as Map<dynamic, dynamic>;
      return {
        'id': staffMap['codigo']?.toString(),
        'name': staffMap['name']?.toString(),
        'state': staffMap['state'] ?? false,
      };
    }).where((member) => member['state'] == true).toList();

    // Eliminar duplicados basados en el ID
    final seen = <String>{};
    staff = staff.where((member) {
      final id = member['id']?.toString();
      if (id == null || seen.contains(id)) return false;
      seen.add(id);
      return true;
    }).toList();

    return showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.white,
          title: Row(
            children: [
              Icon(Icons.medical_services, color: Colors.blue[700]),
              const SizedBox(width: 10),
              const Text(
                'Nueva Tarea',
                style: TextStyle(
                  color: Color(0xFF2641F3),
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
                  const Text('No hay pacientes disponibles')
                else
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Paciente',
                        labelStyle: const TextStyle(color: Color(0xFF2641F3)),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2641F3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.blue[300]!),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2641F3), width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      value: selectedPatient,
                      items: patients.map((patient) {
                        return DropdownMenuItem<String>(
                          value: patient['id'].toString(),
                          child: Text('${patient['name']} (${patient['id']})'),
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
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: 'Descripción de la tarea',
                      labelStyle: const TextStyle(color: Color(0xFF2641F3)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2641F3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2641F3), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    maxLines: 3,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: 'Asignar a (opcional)',
                      labelStyle: const TextStyle(color: Color(0xFF2641F3)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2641F3)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.blue[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF2641F3), width: 2),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    value: selectedStaff,
                    items: [
                      const DropdownMenuItem<String>(
                        value: null,
                        child: Text('Sin asignar'),
                      ),
                      ...staff.map((member) {
                        return DropdownMenuItem<String>(
                          value: member['id'].toString(),
                          child: Text(member['name'].toString()),
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
                if (selectedPatient == null || descriptionController.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Por favor complete todos los campos requeridos'),
                      backgroundColor: Colors.red,
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
                  );

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Tarea creada exitosamente'),
                        backgroundColor: ThemeHospital.getButtonBlue(),
                      ),
                    );
                    if (mounted) {
                      setState(() {
                        GetData().rechargeData();
                      });
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error al crear la tarea: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ThemeHospital.getButtonBlue(),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Crear Tarea',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    GetData().rechargeData();
    
    Widget buildTaskList(bool showCompleted, bool showOnlyMine) {
      return FutureBuilder<List<Task>>(
        future: Tasksfirebase().getTasks(
          widget.codePrefix,
          filterByPatient: widget.showOnlyPatientTasks,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final tasks = snapshot.data ?? [];
            
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
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
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
        },
      );
    }

    Widget content = Column(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: ThemeHospital.getButtonBlue(),
            unselectedLabelColor: Colors.grey,
            indicatorColor: ThemeHospital.getButtonBlue(),
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
              buildTaskList(false, true),  // Mis tareas pendientes
              buildTaskList(false, false), // Todos pendientes
              buildTaskList(true, true),   // Mis tareas realizadas
            ],
          ),
        ),
      ],
    );

    if (widget.showAppBar) {
      return Scaffold(
        appBar: AppBarHospital().getAppBar(),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddTaskDialog(context),
          backgroundColor: ThemeHospital.getButtonBlue(),
          child: const Icon(Icons.add, color: Colors.white),
        ),
        body: content,
      );
    }

    return content;
  }
}
