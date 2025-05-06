import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/sections/Tasks/entitites/Task.dart';
import 'package:mi_hospital/sections/Tasks/entitites/TasksFirebase.dart';  // Tu clase TasksFirebase
import 'package:mi_hospital/sections/Tasks/presentation/widgets_tasks.dart'; // Tu clase WidgetsTask

class TasksScreen extends StatelessWidget {
  final String codePrefix;

  const TasksScreen({Key? key, required this.codePrefix}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:AppBarHospital().getAppBar(),
      body: FutureBuilder<List<Task>>(
        // Cambié el tipo de retorno para que devuelva una lista de objetos Task
        future: Tasksfirebase().getTasks(codePrefix),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final tasks = snapshot.data ?? [];
            if (tasks.isEmpty) {
              return const Center(child: Text('No hay tareas disponibles.'));
            }
            // Aquí, pasamos la lista de tareas (ya convertidas en objetos Task)
            return WidgetsTask(tasks: tasks).listCards(context);
          }
        },
      ),
    );
  }
}
