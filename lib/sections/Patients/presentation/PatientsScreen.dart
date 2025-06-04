import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/Patients/entities/PatientsFirebase.dart';
import 'package:mi_hospital/sections/Patients/presentation/widgets_patients.dart';
import 'package:mi_hospital/sections/Patients/presentation/AddPatientScreen.dart';

class PacientesScreen extends StatefulWidget {
  const PacientesScreen({Key? key}) : super(key: key);

  @override
  _PacientesScreenState createState() => _PacientesScreenState();
}

class _PacientesScreenState extends State<PacientesScreen> {
  final PatientsFirebase _pacienteFirebase = PatientsFirebase();
  List<Map<String, dynamic>> _pacientes = [];
  List<Map<String, dynamic>> _pacientesFiltrados = [];
  final TextEditingController _buscadorController = TextEditingController();

  String _formatearFecha(String fecha) {
    try {
      if (fecha.contains('T')) {
        final dateTime = DateTime.parse(fecha);
        return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year}';
      }
      return fecha;
    } catch (e) {
      return fecha;
    }
  }

  @override
  void initState() {
    super.initState();
    _cargarPacientes();
  }

  Future<void> _cargarPacientes() async {
    final pacientes = await _pacienteFirebase.getPatients(
      GetData().getHospitalCode(),
    );
    setState(() {
      _pacientes = pacientes;
      _pacientesFiltrados = pacientes;
    });
  }

  void _filtrarPacientes(String query) {
    final filtrados = _pacientes.where((paciente) {
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddPatientScreen(),
            ),
          );
        },
        backgroundColor: ThemeController.to.getButtonBlue(),
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: ThemeController.to.getWhite(),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: TextField(
              controller: _buscadorController,
              decoration: InputDecoration(
                hintText: 'Buscar paciente...',
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 16,
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: ThemeController.to.getButtonBlue(),
                  size: 24,
                ),
                filled: true,
                fillColor: ThemeController.to.getBackgroundBlue().withOpacity(0.3),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeController.to.getButtonBlue().withOpacity(0.2),
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeController.to.getButtonBlue().withOpacity(0.2),
                    width: 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: ThemeController.to.getButtonBlue(),
                    width: 2,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: _filtrarPacientes,
            ),
          ),
          Expanded(
            child: _pacientesFiltrados.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person_search,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No se encontraron pacientes',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _cargarPacientes,
                    color: ThemeController.to.getButtonBlue(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(12),
                      itemCount: _pacientesFiltrados.length,
                      itemBuilder: (context, index) {
                        final paciente = _pacientesFiltrados[index];
                        return WidgetsPatients(
                          nombre: paciente['name'],
                          imagenUrl: paciente['img'],
                          cantidadTareas: paciente['task'],
                          habitacion: paciente['roomName'] ?? 'Sin asignar',
                          fechaIngreso: _formatearFecha(paciente['admissionDate'] ?? 'Desconocido'),
                          dni: paciente['dni'],
                          direccion: paciente['address'] ?? '',
                          telefono: paciente['phone'] ?? '',
                          descripcion: paciente['description'] ?? '',
                          id: paciente['id'],
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
