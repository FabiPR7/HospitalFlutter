import 'package:flutter/material.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/Staff/entities/StaffFirebase.dart';
import 'package:get/get.dart';
import 'package:mi_hospital/sections/Message/presentation/message_screen.dart';
import 'package:mi_hospital/sections/Message/entities/MessageFirebase.dart';
import 'dart:async';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';

class WidgetsStaff extends StatefulWidget {
  const WidgetsStaff({Key? key}) : super(key: key);

  @override
  State<WidgetsStaff> createState() => _WidgetsStaffState();
}

class _WidgetsStaffState extends State<WidgetsStaff> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final MessageFirebase _messageFirebase = MessageFirebase();
  Map<String, StreamSubscription> _unreadSubscriptions = {};

  @override
  void dispose() {
    _searchController.dispose();
    // Cancelar todas las suscripciones
    _unreadSubscriptions.values.forEach((subscription) => subscription.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        header(),
        Expanded(child: body()),
      ],
    );
  }

  Widget header() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'Buscar...',
                filled: true,
                fillColor: const Color(0xFFF1F1F1),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade400),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Colors.blue, width: 2),
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                    : null,
              ),
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget body() {
    return FutureBuilder<Widget>(
      future: crearColumnConUsuarios(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          return const Center(child: Text('No se encontraron usuarios.'));
        } else {
          return snapshot.data!;
        }
      },
    );
  }

  Widget estadoCard(String nombre, bool estado, String codigo) {
    return StreamBuilder<int>(
      stream: _messageFirebase.getUnreadMessagesCount(
        GetData().getUserLogin()['codigo'],
        codigo,
      ),
      builder: (context, snapshot) {
        final unreadCount = snapshot.data ?? 0;
        
        return GestureDetector(
          onTap: estado ? () {
            Get.to(() => MessageScreen(
              userId: codigo,
              userName: nombre,
              personalCode: codigo,
              senderCode: GetData().getUserLogin()['codigo'],
            ));
          } : null,
          child: Container(
            height: 65,
            margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 16),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 4,
                        decoration: BoxDecoration(
                          color: estado ? Colors.green : Colors.red,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      nombre,
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      codigo,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey[600],
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                      maxLines: 1,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: estado ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  estado ? 'En turno' : 'Fuera de turno',
                                  style: TextStyle(
                                    color: estado ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      top: -8,
                      right: -8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              ThemeHospital.getButtonBlue(),
                              ThemeHospital.getLightBlue(),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: ThemeHospital.getButtonBlue().withOpacity(0.3),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.message,
                              color: Colors.white,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<Widget> crearColumnConUsuarios() async {
    List<Map> users = await StaffFirebase().getUsersWithSamePrefix(GetData().getHospitalCode());

    // Filtrar usuarios según la búsqueda
    if (_searchQuery.isNotEmpty) {
      users = users.where((user) {
        final name = (user['name'] ?? '').toString().toLowerCase();
        final code = (user['code'] ?? '').toString().toLowerCase();
        return name.contains(_searchQuery) || code.contains(_searchQuery);
      }).toList();
    }

    // Separar usuarios por estado
    List<Map> enTurno = users.where((user) => user['state'] == true).toList();
    List<Map> fueraDeTurno = users.where((user) => user['state'] == false).toList();

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (enTurno.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Personal en turno',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ),
              ...enTurno.map((user) => estadoCard(
                    user['name'] ?? 'Sin nombre',
                    true,
                    user['codigo'] ?? 'Sin código',
                  )),
            ],
            if (fueraDeTurno.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 24, 16, 8),
                child: Text(
                  'Personal fuera de turno',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ),
              ...fueraDeTurno.map((user) => estadoCard(
                    user['name'] ?? 'Sin nombre',
                    false,
                    user['code'] ?? 'Sin código',
                  )),
            ],
            if (enTurno.isEmpty && fueraDeTurno.isEmpty) ...[
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: Text(
                    'No se encontraron resultados',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
