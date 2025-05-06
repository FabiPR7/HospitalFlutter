class Task {
  final String id;
  final String description;
  final String? assignedTo;
  final String createdBy;
  final String patientDni;
  final DateTime timestamp;

  Task({
    required this.id,
    required this.description,
    this.assignedTo,
    required this.createdBy,
    required this.patientDni,
    required this.timestamp,
  });

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      description: map['description'] ?? '',
      assignedTo: map['assignedTo'],
      createdBy: map['createdBy'] ?? '',
      patientDni: map['patientDni'] ?? '',
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime(1900),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'assignedTo': assignedTo,
      'createdBy': createdBy,
      'patientDni': patientDni,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
