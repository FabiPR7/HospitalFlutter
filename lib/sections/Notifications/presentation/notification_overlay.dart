import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mi_hospital/sections/Notifications/presentation/notification_message.dart';

class NotificationOverlay {
  static final NotificationOverlay _instance = NotificationOverlay._internal();
  factory NotificationOverlay() => _instance;
  NotificationOverlay._internal();

  OverlayEntry? _overlayEntry;
  Timer? _timer;

  void show({
    required BuildContext context,
    required String title,
    required String message,
    String? type,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 5),
  }) {
    _hide();

    _overlayEntry = OverlayEntry(
      builder: (context) => NotificationMessage(
        title: title,
        message: message,
        type: type,
        onTap: () {
          _hide();
          onTap?.call();
        },
        onDismiss: _hide,
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);

    _timer = Timer(duration, _hide);
  }

  void _hide() {
    _timer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }
} 