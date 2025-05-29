import 'package:flutter/material.dart';
import 'package:mi_hospital/sections/Patients/presentation/PatientScreen.dart';

class WidgetsPatients extends StatelessWidget {
  final String nombre;
  final String imagenUrl;
  final int cantidadTareas;
  final String habitacion;
  final String fechaIngreso;
  final String dni;
  final String direccion;
  final String telefono;
  final String descripcion;
  final String id;

  const WidgetsPatients({
    Key? key,
    required this.nombre,
    required this.imagenUrl,
    required this.cantidadTareas,
    required this.habitacion,
    required this.fechaIngreso,
    required this.dni,
    required this.direccion,
    required this.telefono,
    required this.descripcion,
    required this.id,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PatientScreen(
                nombre: nombre,
                imagenUrl: imagenUrl,
                habitacion: habitacion,
                fechaIngreso: fechaIngreso,
                dni: dni,
                direccion: direccion,
                telefono: telefono,
                descripcion: descripcion,
                id: id,
              ),
            ),
          );
        },
        leading: CircleAvatar(
          radius: 30,
          backgroundImage: NetworkImage(imagenUrl),
          backgroundColor: Colors.grey[200],
        ),
        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Habitación: $habitacion'),
            Text('Ingreso: $fechaIngreso'),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            cantidadTareas == 1 
              ? '1 tarea' 
              : '$cantidadTareas tareas', 
            style: const TextStyle(color: Colors.blue)
          ),
        ),
      ),
    );
  }
}
