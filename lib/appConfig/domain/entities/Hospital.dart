class Hospital {
  final String nombre;
  final String codigo;

  Hospital({
    required this.nombre,
    required this.codigo,
  });

  // Método para crear desde JSON
  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      nombre: json['nombre'],
      codigo: json['codigo'],
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'codigo': codigo,
    };
  }

  @override
  String toString() => 'Hospital(nombre: $nombre, codigo: $codigo)';
}
