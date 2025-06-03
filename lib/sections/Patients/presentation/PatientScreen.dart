import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/AppBar.dart';
import 'package:mi_hospital/sections/Tasks/presentation/tasks.dart';
import 'package:mi_hospital/sections/Patients/entities/PatientsFirebase.dart';
import 'package:mi_hospital/sections/Rooms/entities/RoomFirebase.dart';
import 'package:mi_hospital/sections/Rooms/entities/Room.dart';
import 'package:mi_hospital/sections/Tasks/entitites/TasksFirebase.dart';
import 'package:mi_hospital/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/sections/Notifications/entities/Notification.dart';
import 'package:mi_hospital/sections/Notifications/infrastructure/NotificationFirebase.dart';
import 'package:mi_hospital/sections/Notifications/presentation/notification_overlay.dart';

class PatientScreen extends StatefulWidget {
  final String nombre;
  final String imagenUrl;
  final String habitacion;
  final String fechaIngreso;
  final String dni;
  final String direccion;
  final String telefono;
  final String descripcion;
  final String id;

  const PatientScreen({
    Key? key,
    required this.nombre,
    required this.imagenUrl,
    required this.habitacion,
    required this.fechaIngreso,
    required this.dni,
    required this.direccion,
    required this.telefono,
    required this.descripcion,
    required this.id,
  }) : super(key: key);

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _darAlta() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Alta'),
        content: const Text('¿Está seguro que desea dar de alta a este paciente?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF48CAE4),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      setState(() => _isLoading = true);
      try {
        final roomFirebase = RoomFirebase();
        final tasksFirebase = Tasksfirebase();
        final notificationFirebase = NotificationFirebase();
        final rooms = await roomFirebase.getRoomsByHospitalCode(GetData().getHospitalCode());
        
        // Encontrar la habitación actual
        final habitacionActual = rooms.firstWhere(
          (room) => room.name == widget.habitacion,
          orElse: () => Room(
            id: widget.habitacion,
            name: widget.habitacion,
            stretches: 0,
            available: 0,
            code: widget.habitacion,
            department: '',
            floor: 0,
          ),
        );

        // Actualizar el estado del paciente
        final dbRef = FirebaseDatabase.instance.ref();
        await dbRef.child('patients').child(widget.id).update({
          'state': 'Alta',
          'dischargeDate': DateTime.now().toIso8601String(),
        });

        // Incrementar el available de la habitación
        await roomFirebase.updateRoomAvailability(
          GetData().getHospitalCode(),
          habitacionActual.name,
          habitacionActual.available + 1
        );

        // Notificar a todos los usuarios activos del hospital
        final staffList = GetData().getStaffList();
        final activeStaff = staffList.where((staff) => 
          staff['state'] == true && 
          staff['hospitalCode'] == GetData().getHospitalCode()
        ).toList();

        for (var staff in activeStaff) {
          if (staff['codigo'] != GetData().getUserLogin()["codigo"]) {
            final notification = AppNotification(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: 'Paciente dado de alta',
              message: '${GetData().getUserLogin()["nombre"]} ha dado de alta al paciente ${widget.nombre} de la habitación ${widget.habitacion}',
              type: 'patient_discharge',
              senderCode: GetData().getUserLogin()["codigo"],
              receiverCode: staff['codigo'],
              timestamp: DateTime.now(),
            );
            await notificationFirebase.createNotification(notification);
          }
        }

        // Obtener y actualizar todas las tareas pendientes del paciente
        final tasks = await tasksFirebase.getTasks(widget.dni, filterByPatient: true);
        for (var task in tasks) {
          if (!task.isDone) {
            await tasksFirebase.markTaskAsDone(task.id);
          }
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Paciente dado de alta y tareas actualizadas exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context); // Regresar a la lista de pacientes
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al dar de alta: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<void> _mostrarDialogoMover() async {
    final roomFirebase = RoomFirebase();
    final notificationFirebase = NotificationFirebase();
    final rooms = await roomFirebase.getRoomsByHospitalCode(GetData().getHospitalCode());
    final List<Map<String, dynamic>> habitaciones = [];
    
    for (var room in rooms) {
      if (room.available > 0 && room.id != widget.habitacion) {
        habitaciones.add({
          'id': room.id,
          'name': room.name,
          'capacity': room.stretches,
          'occupied': room.stretches - room.available,
          'available': room.available,
        });
      }
    }

    if (!mounted) return;

    Map<String, String>? habitacionSeleccionada;
    
    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.door_front_door, color: Colors.blue[700]),
            const SizedBox(width: 10),
            const Text(
              'Mover Paciente',
              style: TextStyle(
                color: Color(0xFF2641F3),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Seleccione la nueva habitación',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              if (habitaciones.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'No hay habitaciones disponibles',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: habitaciones.length,
                    itemBuilder: (context, index) {
                      final habitacion = habitaciones[index];
                      final disponible = habitacion['available'];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            habitacionSeleccionada = {
                              'id': habitacion['id'],
                              'name': habitacion['name'],
                            };
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.door_front_door,
                                    color: Colors.blue[700],
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        habitacion['name'],
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Disponibles: $disponible de ${habitacion['capacity']} camillas',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    if (habitacionSeleccionada != null && mounted) {
      setState(() => _isLoading = true);
      try {
        final id = habitacionSeleccionada?['id'];
        final name = habitacionSeleccionada?['name'];
        
        if (id != null && name != null) {
          await roomFirebase.updatePatientRoom(
            widget.id, 
            id, 
            name
          );
          await roomFirebase.updateRoomsOccupancy(
            widget.habitacion,
            id
          );

          // Notificar a todos los usuarios activos excepto al que realizó el cambio
          final staffList = GetData().getStaffList();
          final activeStaff = staffList.where((staff) => 
            staff['state'] == true && 
            staff['hospitalCode'] == GetData().getHospitalCode()
          ).toList();

          for (var staff in activeStaff) {
            if (staff['codigo'] != GetData().getUserLogin()["codigo"]) {
              final notification = AppNotification(
                id: DateTime.now().millisecondsSinceEpoch.toString() + '_${staff['codigo']}',
                title: 'Cambio de habitación',
                message: '${GetData().getUserLogin()["nombre"]} ha movido al paciente ${widget.nombre} de la habitación ${widget.habitacion} a ${name}',
                type: 'room_change',
                senderCode: GetData().getUserLogin()["codigo"],
                receiverCode: staff['codigo'],
                timestamp: DateTime.now(),
              );
              await notificationFirebase.createNotification(notification);
            }
          }

          // Mostrar notificación flotante al usuario que realizó el cambio
          if (mounted) {
            NotificationOverlay().show(
              context: context,
              title: 'Paciente movido',
              message: 'Has movido a ${widget.nombre} a la habitación $name',
              type: 'room_change',
            );
          }

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Paciente movido exitosamente'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al mover al paciente: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Widget _buildInfoSection() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(widget.imagenUrl),
              backgroundColor: Colors.grey[200],
            ),
          ),
          const SizedBox(height: 24),
          _buildInfoCard('Información Personal', [
            _buildInfoRow('Nombre', widget.nombre),
            _buildInfoRow('DNI', widget.dni),
            _buildInfoRow('Dirección', widget.direccion),
            _buildInfoRow('Teléfono', widget.telefono),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Información Hospitalaria', [
            _buildInfoRow('Habitación', widget.habitacion),
            _buildInfoRow('Fecha de Ingreso', widget.fechaIngreso),
          ]),
          const SizedBox(height: 16),
          _buildInfoCard('Descripción', [
            _buildInfoRow('', widget.descripcion),
          ]),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: _isLoading ? null : _mostrarDialogoMover,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48CAE4),
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.door_front_door, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Mover',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: _isLoading ? null : _darAlta,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_outline, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Dar de Alta',
                            style: TextStyle(fontSize: 16, color: Colors.white),
                          ),
                        ],
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF48CAE4),
              ),
            ),
            const Divider(),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (label.isNotEmpty) ...[
            SizedBox(
              width: 100,
              child: Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const SizedBox(width: 16),
          ],
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarHospital().getAppBar(),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF48CAE4),
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              indicatorColor: Colors.white,
              tabs: const [
                Tab(text: 'Información'),
                Tab(text: 'Tareas'),
              ],
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoSection(),
                Scaffold(
                  body: TasksScreen(
                    codePrefix: widget.dni,
                    showOnlyPatientTasks: true,
                    showAppBar: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 