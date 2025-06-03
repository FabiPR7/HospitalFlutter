import 'package:flutter/material.dart';
import 'package:mi_hospital/sections/Notifications/entities/Notification.dart';
import 'package:mi_hospital/sections/Notifications/infrastructure/NotificationFirebase.dart';
import 'package:mi_hospital/main.dart';

class DrawerMenu extends StatelessWidget {
  final String userName;
  final String code;

  const DrawerMenu({
    Key? key,
    required this.userName,
    required this.code,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationFirebase = NotificationFirebase();

    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              const Color(0xFF2196F3).withOpacity(0.05),
              const Color(0xFF64B5F6).withOpacity(0.1),
            ],
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 40, bottom: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF1976D2),
                    const Color(0xFF2196F3),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userName,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Código: $code',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<List<AppNotification>>(
                stream: notificationFirebase.getNotificationsForUser(code),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1976D2),
                      ),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.notifications_off_outlined,
                            size: 64,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No hay notificaciones nuevas',
                            style: TextStyle(
                              color: Colors.grey.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  final hasUnread = snapshot.data!.any((notification) => !notification.isRead);

                  return Column(
                    children: [
                      if (hasUnread)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ElevatedButton.icon(
                            onPressed: () {
                              notificationFirebase.markAllAsRead(code);
                            },
                            icon: const Icon(Icons.done_all),
                            label: const Text('Marcar todas como leídas'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1976D2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: snapshot.data!.length,
                          itemBuilder: (context, index) {
                            final notification = snapshot.data![index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: notification.isRead 
                                    ? const Color(0xFFF5F7FA)
                                    : const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: notification.isRead
                                      ? const Color(0xFFE0E0E0)
                                      : const Color(0xFF90CAF9),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: notification.isRead
                                        ? Colors.black.withOpacity(0.02)
                                        : const Color(0xFF1976D2).withOpacity(0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: () {
                                    notificationFirebase.markAsRead(notification.id);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.all(8),
                                              decoration: BoxDecoration(
                                                color: notification.isRead
                                                    ? const Color(0xFFEEEEEE)
                                                    : const Color(0xFFBBDEFB),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Icon(
                                                notification.type == 'task' ? Icons.task : Icons.notifications,
                                                color: notification.isRead
                                                    ? const Color(0xFF757575)
                                                    : const Color(0xFF1976D2),
                                                size: 20,
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Text(
                                                notification.title,
                                                style: TextStyle(
                                                  fontWeight: notification.isRead
                                                      ? FontWeight.normal
                                                      : FontWeight.bold,
                                                  color: notification.isRead
                                                      ? const Color(0xFF616161)
                                                      : const Color(0xFF1565C0),
                                                  fontSize: 15,
                                                ),
                                              ),
                                            ),
                                            Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: notification.isRead
                                                    ? const Color(0xFFEEEEEE)
                                                    : const Color(0xFFBBDEFB),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                _formatTimestamp(notification.timestamp),
                                                style: TextStyle(
                                                  color: notification.isRead
                                                      ? const Color(0xFF757575)
                                                      : const Color(0xFF1976D2),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          notification.message,
                                          style: TextStyle(
                                            color: notification.isRead
                                                ? const Color(0xFF757575)
                                                : const Color(0xFF424242),
                                            fontSize: 12,
                                            height: 1.2,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Ahora';
    }
  }
} 