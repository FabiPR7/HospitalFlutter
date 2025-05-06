import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/sections/Rooms/entities/Room.dart';

class HabitacionFirebase {
  Future<List<Room>> getRoomsByHospitalCode(String hospitalCode) async {
    final databaseRef = FirebaseDatabase.instance.ref('rooms');
    try {
      final snapshot = await databaseRef.get();
      List<Room> roomsList = [];

      if (snapshot.exists) {
        Map<dynamic, dynamic> roomsData = snapshot.value as Map<dynamic, dynamic>;

        roomsData.forEach((key, value) {
          if (value['code'] == hospitalCode) {
            final roomMap = Map<String, dynamic>.from(value);
            roomsList.add(Room.fromMap(key, roomMap));
          }
        });
      }

      return roomsList;
    } catch (e) {
      print('Error fetching rooms: $e');
      return [];
    }
  }
}
