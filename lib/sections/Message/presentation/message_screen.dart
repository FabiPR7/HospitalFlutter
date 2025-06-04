import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'message_widget.dart';
import 'package:mi_hospital/sections/Message/entities/MessageFirebase.dart';
import 'package:mi_hospital/main.dart';

class MessageScreen extends StatelessWidget {
  final String userId;
  final String userName;
  final String personalCode;
  final String senderCode;
  final MessageFirebase _messageFirebase = MessageFirebase();

  MessageScreen({
    Key? key,
    required this.userId,
    required this.userName,
    required this.personalCode,
    required this.senderCode,
  }) : super(key: key) {
    _markMessagesAsRead();
  }

  void _markMessagesAsRead() {
    final currentUserCode = GetData().getUserLogin()['codigo'];
    _messageFirebase.markMessagesAsRead(personalCode, currentUserCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              ThemeController.to.getBackgroundBlue().withOpacity(0.1),
              ThemeController.to.getLightBlue().withOpacity(0.2),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      ThemeController.to.getButtonBlue(),
                      ThemeController.to.getLightBlue(),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                      ),
                      onPressed: () => Get.back(),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: ThemeController.to.getLightBlue(),
                        child: Text(
                          userName.isNotEmpty ? userName[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.green.withOpacity(0.3),
                                      blurRadius: 4,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'En línea',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.more_vert, color: Colors.white, size: 20),
                      ),
                      onPressed: () {
                        // TODO: Implementar menú de opciones
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: MessageWidget(
                  userId: userId,
                  userName: userName,
                  personalCode: personalCode,
                  senderCode: senderCode,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 