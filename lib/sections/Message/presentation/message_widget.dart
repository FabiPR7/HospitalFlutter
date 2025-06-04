import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'package:mi_hospital/sections/Message/entities/Message.dart';
import 'package:mi_hospital/sections/Message/entities/MessageFirebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:mi_hospital/main.dart';

class MessageWidget extends StatefulWidget {
  final String userId;
  final String userName;
  final String personalCode;
  final String senderCode;

  const MessageWidget({
    Key? key,
    required this.userId,
    required this.userName,
    required this.personalCode,
    required this.senderCode,
  }) : super(key: key);

  @override
  State<MessageWidget> createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final MessageFirebase _messageFirebase = MessageFirebase();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<Message> _messages = [];
  StreamSubscription? _messagesSubscription;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  
    _refreshTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      _loadMessages();
    });
  }

  void _loadMessages() {
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId != null) {
      _messagesSubscription?.cancel(); 
      _messagesSubscription = _messageFirebase.getMessages(currentUserId, widget.userId).listen((messages) {
        if (mounted) {
          setState(() {
           _messages = messages;
          });
          _scrollToBottom();
        }
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messagesSubscription?.cancel();
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) return;

    final message = Message(
      id: '',
      senderId: GetData().getUserLogin()['codigo'],
      receiverId: widget.userId,
      personalCode: widget.personalCode,
      senderCode: widget.senderCode,
      senderIdCode: GetData().getUserLogin()['codigo'],
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
    );

    try {
      await _messageFirebase.sendMessage(message);
      _messageController.clear();
      _scrollToBottom();
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo enviar el mensaje',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUserCode = GetData().getUserLogin()['codigo'];

    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            itemCount: _messages.length,
            itemBuilder: (context, index) {
              final message = _messages[index];
              // Si soy el remitente (senderId)
              final isMe = message.senderId == currentUserCode;
              
              return Align(
                alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: EdgeInsets.only(
                    bottom: 8,
                    left: isMe ? 64 : 0,
                    right: isMe ? 0 : 64,
                  ),
                  child: Column(
                    crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: isMe 
                              ? ThemeController.to.getButtonBlue()
                              : ThemeController.to.getCardColor(),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.content,
                              style: TextStyle(
                                color: isMe ? Colors.white : ThemeController.to.getTextColor(),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatTime(message.timestamp),
                              style: TextStyle(
                                color: isMe ? Colors.white70 : ThemeController.to.getGrey(),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 4, left: 4, right: 4),
                        child: Text(
                          isMe ? message.senderCode : message.personalCode,
                          style: TextStyle(
                            color: ThemeController.to.getGrey(),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: ThemeController.to.getCardColor(),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, -1),
              ),
            ],
          ),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.attach_file,
                  color: ThemeController.to.getButtonBlue(),
                ),
                onPressed: () {
                  // TODO: Implementar adjuntar archivos
                },
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: ThemeController.to.getSurfaceColor(),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: TextStyle(color: ThemeController.to.getTextColor()),
                    decoration: InputDecoration(
                      hintText: 'Escribe un mensaje...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(
                        color: ThemeController.to.getGrey(),
                      ),
                    ),
                    maxLines: null,
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                decoration: BoxDecoration(
                  color: ThemeController.to.getButtonBlue(),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.send,
                    color: Colors.white,
                  ),
                  onPressed: _sendMessage,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 