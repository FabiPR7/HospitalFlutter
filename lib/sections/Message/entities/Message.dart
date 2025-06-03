class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String personalCode;
  final String senderCode;
  final String senderIdCode;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final String? imageUrl;
  final String? fileUrl;
  final String? fileName;
  final MessageType type;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.personalCode,
    required this.senderCode,
    required this.senderIdCode,
    required this.content,
    required this.timestamp,
    required this.isRead,
    this.imageUrl,
    this.fileUrl,
    this.fileName,
    this.type = MessageType.text,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'personalCode': personalCode,
      'senderCode': senderCode,
      'senderIdCode': senderIdCode,
      'content': content,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isRead': isRead,
      'imageUrl': imageUrl,
      'fileUrl': fileUrl,
      'fileName': fileName,
      'type': type.toString(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      personalCode: map['personalCode'] ?? '',
      senderCode: map['senderCode'] ?? '',
      senderIdCode: map['senderIdCode'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : DateTime.now(),
      isRead: map['isRead'] ?? false,
      imageUrl: map['imageUrl'],
      fileUrl: map['fileUrl'],
      fileName: map['fileName'],
      type: MessageType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => MessageType.text,
      ),
    );
  }
}

enum MessageType {
  text,
  image,
  file,
  location,
} 