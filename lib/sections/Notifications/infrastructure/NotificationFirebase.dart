import 'package:firebase_database/firebase_database.dart';
import 'package:mi_hospital/sections/Notifications/entities/Notification.dart';

class NotificationFirebase {
  final DatabaseReference _notificationsRef = FirebaseDatabase.instance.ref().child('notifications');

  // Crear una nueva notificación
  Future<void> createNotification(AppNotification notification) async {
    try {
      // Crear la notificación directamente con un ID único
      await _notificationsRef.child(notification.id).set(notification.toMap());
    } catch (e) {
      print('Error al crear notificación: $e');
      throw Exception('Error al crear notificación: $e');
    }
  }

  // Obtener notificaciones para un usuario específico
  Stream<List<AppNotification>> getNotificationsForUser(String userCode) {
    return _notificationsRef
        .orderByChild('receiverCode')
        .equalTo(userCode)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return [];
      
      final Map<dynamic, dynamic> data = event.snapshot.value as Map;
      return data.entries.map((entry) {
        final Map<String, dynamic> notificationData = Map<String, dynamic>.from(entry.value as Map);
        notificationData['id'] = entry.key;
        return AppNotification.fromMap(notificationData);
      }).toList()
        ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    });
  }

  // Marcar una notificación como leída
  Future<void> markAsRead(String notificationId) async {
    await _notificationsRef.child(notificationId).update({'isRead': true});
  }

  // Obtener el conteo de notificaciones no leídas
  Stream<int> getUnreadCount(String userCode) {
    return _notificationsRef
        .orderByChild('receiverCode')
        .equalTo(userCode)
        .onValue
        .map((event) {
      if (event.snapshot.value == null) return 0;
      
      final Map<dynamic, dynamic> data = event.snapshot.value as Map;
      return data.values.where((notification) {
        final Map<String, dynamic> notificationData = Map<String, dynamic>.from(notification as Map);
        return notificationData['receiverCode'] == userCode && 
               (notificationData['isRead'] == null || notificationData['isRead'] == false);
      }).length;
    });
  }

  // Marcar todas las notificaciones como leídas
  Future<void> markAllAsRead(String userCode) async {
    final snapshot = await _notificationsRef
        .orderByChild('receiverCode')
        .equalTo(userCode)
        .get();

    if (snapshot.value != null) {
      final Map<dynamic, dynamic> data = snapshot.value as Map;
      final batch = <Future<void>>[];
      
      data.forEach((key, value) {
        final Map<String, dynamic> notificationData = Map<String, dynamic>.from(value as Map);
        if (notificationData['isRead'] == null || notificationData['isRead'] == false) {
          batch.add(_notificationsRef.child(key).update({'isRead': true}));
        }
      });

      await Future.wait(batch);
    }
  }
} 