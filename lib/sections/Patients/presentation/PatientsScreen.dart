import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/sections/Patients/entities/PatientsFirebase.dart';
import 'package:mi_hospital/sections/Patients/presentation/widgets_patients.dart';

class PacientesScreen extends StatefulWidget {
  const PacientesScreen({Key? key}) : super(key: key);

  @override
  _PacientesScreenState createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  final PatientsFirebase _pacienteFirebase = PatientsFirebase();
  List<Map<String, dynamic>> _pacientes = [];
  List<Map<String, dynamic>> _pacientesFiltrados = [];
  final String codigoHospital = 'H001';
  final TextEditingController _buscadorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
  }

  Future<void> _cargarPacientes() async {
    final pacientes = await _pacienteFirebase.getPatients(
      codigoHospital,
    );
    setState(() {
      _pacientes = pacientes;
      _pacientesFiltrados = pacientes;
    });
  }

  void _filtrarPacientes(String query) {
    final filtrados =
        _pacientes.where((paciente) {
          final nombre = paciente['name'].toLowerCase();
          return nombre.contains(query.toLowerCase());
        }).toList();

    setState(() {
      _pacientesFiltrados = filtrados;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHospital().getAppBar(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _buscadorController,
              decoration: InputDecoration(
                hintText: 'Buscar paciente...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.blue[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: _filtrarPacientes,
            ),
          ),
          Expanded(
            child:
                _pacientesFiltrados.isEmpty
                    ? const Center(child: Text('No se encontraron pacientes'))
                    : ListView.builder(
                      itemCount: _pacientesFiltrados.length,
                      itemBuilder: (context, index) {
                        final paciente = _pacientesFiltrados[index];
                        return WidgetsPatients(
                          nombre: paciente['name'],
                          imagenUrl: paciente['img'],
                          cantidadTareas: paciente['task'].length,
                          habitacion: paciente['roomName'] ?? 'Sin asignar',
                          fechaIngreso:
                              paciente['admissionDate'] ??
                              'Desconocido', // <-- AGREGADO
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
