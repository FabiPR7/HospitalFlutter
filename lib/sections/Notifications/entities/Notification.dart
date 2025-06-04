class AppNotification {
  final String id;
  final String title;
  final String message;
  final String type;
  final String senderCode;
  final String receiverCode;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.senderCode,
    required this.receiverCode,
    required this.timestamp,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type,
      'senderCode': senderCode,
      'receiverCode': receiverCode,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }

  factory AppNotification.fromMap(Map<String, dynamic> map) {
    return AppNotification(
      id: map['id'],
      title: map['title'],
      message: map['message'],
      type: map['type'],
      senderCode: map['senderCode'],
      receiverCode: map['receiverCode'],
      timestamp: DateTime.parse(map['timestamp']),
      isRead: map['isRead'] ?? false,
    );
  }
} 