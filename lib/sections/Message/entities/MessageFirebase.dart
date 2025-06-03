import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/sections/Message/entities/Message.dart';
import 'package:mi_hospital/main.dart';

class MessageFirebase {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String _collection = 'messages';

  Future<void> sendMessage(Message message) async {
    try {
      final messageRef = _database.child(_collection).push();
      
      final messageData = {
        'id': messageRef.key,
        'senderId': message.senderId,
        'receiverId': message.receiverId,
        'content': message.content,
        'timestamp': ServerValue.timestamp,
        'isRead': false,
        'type': 'text',
      };

      await messageRef.set(messageData);
      
      await _updateLastMessage(message);
      
      print('Mensaje enviado correctamente: ${messageData}');
    } catch (e) {
      print('Error al enviar mensaje: $e');
      throw Exception('Error al enviar mensaje: $e');
    }
  }

  Stream<List<Message>> getMessages(String userId1, String userId2) {
    try {
      final currentUserCode = GetData().getUserLogin()['codigo'];
      
      return _database
          .child(_collection)
          .orderByChild('timestamp')
          .onValue
          .map((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data == null) return [];

        final messages = <Message>[];
        data.forEach((key, value) {
          final messageData = Map<String, dynamic>.from(value as Map);
          if ((messageData['senderId'] == currentUserCode && messageData['receiverId'] == userId2) ||
              (messageData['senderId'] == userId2 && messageData['receiverId'] == currentUserCode)) {
            messageData['id'] = key;
            messages.add(Message.fromMap(messageData));
          }
        });

        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        return messages;
      });
    } catch (e) {
      print('Error al obtener mensajes: $e');
      throw Exception('Error al obtener mensajes: $e');
    }
  }

  Future<void> markMessagesAsRead(String senderId, String receiverId) async {
    try {
      final messagesRef = _database.child(_collection);
      final messages = await messagesRef
          .orderByChild('senderId')
          .equalTo(senderId)
          .get();

      if (messages.value != null) {
        final data = messages.value as Map<dynamic, dynamic>;
        data.forEach((key, value) {
          final messageData = Map<String, dynamic>.from(value as Map);
          if (messageData['receiverId'] == receiverId && !messageData['isRead']) {
            messagesRef.child(key).update({'isRead': true});
          }
        });
      }
    } catch (e) {
      print('Error al marcar mensajes como leídos: $e');
      throw Exception('Error al marcar mensajes como leídos: $e');
    }
  }

  Future<void> _updateLastMessage(Message message) async {
    try {
      final chatId = _getChatId(message.senderId, message.receiverId);
      await _database.child('chats').child(chatId).set({
        'lastMessage': message.content,
        'lastMessageTime': ServerValue.timestamp,
        'participants': [message.senderId, message.receiverId],
        'unreadCount': ServerValue.increment(1),
      });
    } catch (e) {
      print('Error al actualizar último mensaje: $e');
      throw Exception('Error al actualizar último mensaje: $e');
    }
  }

  String _getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _database.child(_collection).child(messageId).remove();
    } catch (e) {
      print('Error al eliminar mensaje: $e');
      throw Exception('Error al eliminar mensaje: $e');
    }
  }

  Stream<int> getUnreadMessagesCount(String receiverCode, String senderCode) {
    try {
      return _database
          .child(_collection)
          .orderByChild('receiverId')
          .equalTo(receiverCode)
          .onValue
          .map((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data == null) return 0;

        int unreadCount = 0;
        data.forEach((key, value) {
          final messageData = Map<String, dynamic>.from(value as Map);
          if (messageData['senderId'] == senderCode && messageData['isRead'] == false) {
            unreadCount++;
          }
        });
        return unreadCount;
      });
    } catch (e) {
      print('Error al verificar mensajes no leídos: $e');
      return Stream.value(0);
    }
  }

  Stream<bool> hasUnreadMessages(String receiverCode, String senderCode) {
    try {
      return _database
          .child(_collection)
          .orderByChild('receiverId')
          .equalTo(receiverCode)
          .onValue
          .map((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data == null) return false;

        bool hasUnread = false;
        data.forEach((key, value) {
          final messageData = Map<String, dynamic>.from(value as Map);
          if (messageData['senderId'] == senderCode && messageData['isRead'] == false) {
            hasUnread = true;
          }
        });
        return hasUnread;
      });
    } catch (e) {
      print('Error al verificar mensajes no leídos: $e');
      return Stream.value(false);
    }
  }
} 