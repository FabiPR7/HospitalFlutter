class Task {
  final String id;
  final String description;
  final String patientDni;
  final String createdBy;
  final String? assignedTo;
  final DateTime timestamp;
  final bool isDone;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.description,
    required this.patientDni,
    required this.createdBy,
    this.assignedTo,
    required this.timestamp,
    this.isDone = false,
    this.completedAt,
  });

  factory Task.fromMap(String id, Map<String, dynamic> map) {
    return Task(
      id: id,
      description: map['description'] ?? '',
      patientDni: map['patientDni'] ?? '',
      createdBy: map['createdBy'] ?? '',
      assignedTo: map['assignedTo']?.toString(),
      timestamp: DateTime.tryParse(map['timestamp'] ?? '') ?? DateTime.now(),
      isDone: map['isDone'] ?? false,
      completedAt: map['completedAt'] != null 
        ? DateTime.fromMillisecondsSinceEpoch(map['completedAt'])
        : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'description': description,
      'patientDni': patientDni,
      'createdBy': createdBy,
      'assignedTo': assignedTo,
      'timestamp': timestamp.toIso8601String(),
      'isDone': isDone,
      'completedAt': completedAt?.millisecondsSinceEpoch,
    };
  }
}
