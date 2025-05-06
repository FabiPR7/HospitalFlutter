
class Room {
  final String id; // ID único de la habitación (puede ser el código único que aparece en la base de datos)
  final int available; // Número de camas disponibles
  final String code; // Código de la habitación
  final String department; // Departamento (ej. Pediatría)
  final int floor; // Piso donde se encuentra la habitación
  final String name; // Nombre de la habitación (ej. B2)
  final int stretches; // Número de camillas en la habitación

Room({
  required this.id,
  required this.available,
  required this.code,
  required this.department,
  required this.floor,
  required this.name,
  required this.stretches,
});


 

  // Método para convertir de un objeto Room a un Map (útil para escribir en Firebase)
  factory Room.fromMap(String id, Map<String, dynamic> data) {
  return Room(
    id: id,
    available: data['available'] ?? 0,
    code: data['code'] ?? '',
    department: data['department'] ?? '', // 👈 Usa la clave correcta
    floor: data['floor'] ?? 0,
    name: data['name'] ?? '',
    stretches: data['stretches'] ?? 0,
  );
}

}
