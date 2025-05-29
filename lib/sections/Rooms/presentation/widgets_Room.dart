import 'package:flutter/material.dart';
import 'package:mi_hospital/sections/Rooms/entities/Room.dart';
import 'package:mi_hospital/sections/Rooms/entities/RoomFirebase.dart';
import 'package:mi_hospital/sections/Rooms/presentation/RoomOptionsDialog.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';

class WidgetsRoom extends StatefulWidget {
  final String hospitalCode;

  const WidgetsRoom({super.key, required this.hospitalCode});

  @override
  State<WidgetsRoom> createState() => WidgetsRoomState();
}

class WidgetsRoomState extends State<WidgetsRoom> {
  List<Room> rooms = [];
  List<Room> filteredRooms = [];
  bool isLoading = true;
  int? selectedFloor;
  String? selectedAvailability;
  bool showOnlyAvailable = false;

  @override
  void initState() {
    super.initState();
    fetchRooms();
  }

  Future<void> fetchRooms() async {
    RoomFirebase roomFirebase = RoomFirebase();
  final fetchedRooms = await roomFirebase.getRoomsByHospitalCode(
      widget.hospitalCode,
    );
    setState(() {
     rooms = fetchedRooms; 
      filteredRooms = fetchedRooms;
      isLoading = false;
    });
  }

  List<int> getUniqueFloors() {
    return rooms.map((room) => room.floor).toSet().toList()..sort();
  }

  void applyFilters() {
    setState(() {
      filteredRooms = rooms.where((room) {
        // Filtro de piso
        bool matchesFloor = selectedFloor == null || room.floor == selectedFloor;
        
        // Filtro de disponibilidad
        bool matchesAvailability = !showOnlyAvailable || (room.available > 0);
        
        return matchesFloor && matchesAvailability;
      }).toList();
    });
  }

  Widget buildFilters() {
    final floors = getUniqueFloors();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          PopupMenuButton<int?>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: selectedFloor != null ? ThemeHospital.getLightBlue() : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.layers,
                    color: selectedFloor != null ? ThemeHospital.getWhite() : Colors.grey[700],
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    selectedFloor != null ? 'Piso $selectedFloor' : 'Piso',
                    style: TextStyle(
                      color: selectedFloor != null ? ThemeHospital.getWhite() : Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            itemBuilder: (context) => [
              PopupMenuItem<int?>(
                value: null,
                child: Text(
                  'Todos los pisos',
                  style: TextStyle(
                    color: selectedFloor == null ? ThemeHospital.getLightBlue() : Colors.black,
                    fontWeight: selectedFloor == null ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              ...floors.map((floor) => PopupMenuItem<int?>(
                value: floor,
                child: Text(
                  'Piso $floor',
                  style: TextStyle(
                    color: selectedFloor == floor ? ThemeHospital.getLightBlue() : Colors.black,
                    fontWeight: selectedFloor == floor ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              )),
            ],
            onSelected: (value) {
              setState(() {
                selectedFloor = value;
              });
              applyFilters();
            },
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                showOnlyAvailable = !showOnlyAvailable;
              });
              applyFilters();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: showOnlyAvailable ? ThemeHospital.getLightBlue() : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.bed,
                    color: showOnlyAvailable ? ThemeHospital.getWhite() : Colors.grey[700],
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Disponibles',
                    style: TextStyle(
                      color: showOnlyAvailable ? ThemeHospital.getWhite() : Colors.grey[700],
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildRoomCard(Room room) {
    final occupied = (room.stretches - room.available).clamp(0, room.stretches);

    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (context) => RoomOptionsDialog(
            room: room,
            onRoomDeleted: () {
              setState(() {
                rooms.removeWhere((r) => r.id == room.id);
                filteredRooms.removeWhere((r) => r.id == room.id);
              });
            },
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
        color: room.stretches != occupied
            ? ThemeHospital.getWhite()
            : ThemeHospital.getErrorRed(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              getTextRoom(room, room.name, 20),
              const SizedBox(height: 8),
              getTextRoom(room, 'Departamento: ${room.department}', 14),
              const SizedBox(height: 4),
              getTextRoom(room, 'Piso: ${room.floor}', 14),
              const SizedBox(height: 12),
              getCardStretches(room),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildRoomList() {
    return RefreshIndicator(
      onRefresh: fetchRooms,
      child: Column(
        children: [
          buildFilters(),
          Expanded(
            child: ListView.builder(
              itemCount: filteredRooms.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                return buildRoomCard(filteredRooms[index]);
              },
              ),
            ),
        ],
      ),
    );
  }

  Widget getTextRoom(Room room, String text, double fontSize) {
    final occupied = (room.stretches - room.available).clamp(0, room.stretches);
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: room.stretches != occupied
            ? ThemeHospital.getLightBlue()
            : ThemeHospital.getWhite(),
      ),
    );
  }

  Widget getCardStretches(Room room) {
    final occupied = (room.stretches - room.available).clamp(0, room.stretches);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
      decoration: BoxDecoration(
        color: room.stretches != occupied
            ? ThemeHospital.getBackgroundBlue()
            : ThemeHospital.getWhite(),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${room.stretches}/$occupied camillas',
        style: TextStyle(
          fontSize: 14,
          color: room.stretches != occupied
              ? ThemeHospital.getDarkBlue()
              : ThemeHospital.getErrorRed(),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (rooms.isEmpty) {
      return const Center(
        child: Text('No se encontraron habitaciones de hospital'),
      );
    }

    return buildRoomList();
  }
}
