import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'package:mi_hospital/sections/Notifications/infrastructure/NotificationFirebase.dart';
import 'package:mi_hospital/main.dart';

class WidgetsMainMenu {

  Widget imageButtonBySrc(String src, double h, bool enabled, [VoidCallback? onPressed]) {
    return Opacity(
      opacity: enabled ? 1.0 : 0.4,
      child: IconButton(
        onPressed: enabled ? onPressed : null,
        icon: Image.asset(src, height: h),
      ),
    );
  }

  AppBar appBarMenu(GlobalKey<ScaffoldState> scaffoldKey) {
    final notificationFirebase = NotificationFirebase();
    final userCode = GetData().getUserLogin()['codigo'];

    return AppBar(
      leading: Stack(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            child: IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                scaffoldKey.currentState?.openDrawer();
              },
            ),
          ),
          StreamBuilder<int>(
            stream: notificationFirebase.getUnreadCount(userCode),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data! > 0) {
                return Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      snapshot.data.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      title: Image.asset("assets/images/log/logo.png", height: 50),
      backgroundColor: const Color(0xFF2196F3),
    );
  }

}
