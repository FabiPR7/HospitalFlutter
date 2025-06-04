
class Room {
    final String id;
  final int available;
  final String code;
  final String department;
  final int floor;
  final String name;
  final int stretches;

Room({
  required this.id,
  required this.available,
  required this.code,
  required this.department,
  required this.floor,
  required this.name,
  required this.stretches,
});


 


  factory Room.fromMap(String id, Map<String, dynamic> data) {
  return Room(
    id: id,
    available: data['available'] ?? 0,
    code: data['code'] ?? '',
    department: data['department'] ?? '', 
    floor: data['floor'] ?? 0,
    name: data['name'] ?? '',
    stretches: data['stretches'] ?? 0,
  );
}

}
