import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/sections/Rooms/entities/Room.dart';

class RoomFirebase {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  Future<List<Room>> getRoomsByHospitalCode(String hospitalCode) async {
    try {
      final snapshot = await _dbRef.child('rooms').get();
      List<Room> roomsList = [];

      if (snapshot.exists) {
        final roomsData = snapshot.value as Map<dynamic, dynamic>;

        roomsData.forEach((key, value) {
          if (value['code'] == hospitalCode) {
            final roomMap = Map<String, dynamic>.from(value);
            roomsList.add(Room.fromMap(key, roomMap));
          }
        });
      }

      return roomsList;
    } catch (e) {
      return [];
    }
  }

  Future<void> insertRoom({
    required String name,
    required String department,
    required int floor,
    required int stretches,
    required String code,
  }) async {
    final databaseRef = FirebaseDatabase.instance.ref('rooms');
    try {
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        final roomsData = snapshot.value as Map<dynamic, dynamic>;
        for (var entry in roomsData.entries) {
          final roomData = entry.value as Map<dynamic, dynamic>;
          if (roomData['code'] == code && roomData['name'] == name) {
            throw Exception('Ya existe una habitación con el nombre "$name" en este hospital.');
          }
        }
      }

      final newRoomRef = databaseRef.push();
      await newRoomRef.set({
        'name': name,
        'department': department,
        'floor': floor,
        'stretches': stretches,
        'available': stretches,
        'code': code,
      });
    } catch (e) {
      throw e;
    }
  }

   Future<void> deleteRoom(String roomId) async {
    final databaseRef = FirebaseDatabase.instance.ref('rooms');
    try {
      await databaseRef.child(roomId).remove();
    } catch (e) {
      print('Error deleting room: $e');
      throw e;
    }
  }

  Future<void> updateRoomAvailability(String hospitalCode, String roomName, int newAvailable) async {
    try {
      final snapshot = await _dbRef.child('rooms').get();
      if (snapshot.exists) {
        final roomsData = snapshot.value as Map<dynamic, dynamic>;
        for (var entry in roomsData.entries) {
          final roomData = entry.value as Map<dynamic, dynamic>;
          if (roomData['code'] == hospitalCode && roomData['name'] == roomName) {
            await _dbRef.child('rooms').child(entry.key).update({
              'available': newAvailable,
            });
            break;
          }
        }
      }
    } catch (e) {
      throw e;
    }
  }

  Future<void> updatePatientRoom(String patientId, String newRoomId, String newRoomName) async {
    try {
      await _dbRef.child('patients').child(patientId).update({
        'room': newRoomId,
        'roomName': newRoomName,
      });
    } catch (e) {
      throw e;
    }
  }

  Future<void> updateRoomsOccupancy(String currentRoomName, String newRoomId) async {
    try {
      final snapshot = await _dbRef.child('rooms').get();
      if (snapshot.exists) {
        final roomsData = snapshot.value as Map<dynamic, dynamic>;
        
        String? currentRoomId;
        for (var entry in roomsData.entries) {
          final roomData = entry.value as Map<dynamic, dynamic>;
          if (roomData['name'] == currentRoomName) {
            currentRoomId = entry.key;
            break;
          }
        }

        if (currentRoomId != null) {
          await _dbRef.child('rooms').child(currentRoomId).update({
            'available': ServerValue.increment(1),
          });
        }

        await _dbRef.child('rooms').child(newRoomId).update({
          'available': ServerValue.increment(-1),
        });
      }
    } catch (e) {
      throw e;
    }
  }
}
