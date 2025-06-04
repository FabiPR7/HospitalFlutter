import 'package:flutter/material.dart';
import 'package:mi_hospital/appConfig/domain/sqlite/Sqlite.dart';
import 'package:mi_hospital/sections/Sign_in/presentation/sign_in.dart';
import 'package:mi_hospital/appConfig/presentation/theme/Theme.dart';
import 'package:mi_hospital/sections/Settings/domain/notifications_controller.dart';
import 'package:get/get.dart';

class WidgetsSettings {
  static Future<void> _logout(BuildContext context) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Cierre de Sesión'),
        content: const Text('¿Está seguro que desea cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF48CAE4),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmacion == true) {
      try {
        final dbHelper = DatabaseHelper();
        await dbHelper.logout();
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => SignInScreen()),
          (route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No se pudo cerrar sesión correctamente. Por favor, intente nuevamente.'),
            backgroundColor: Colors.red[100],
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  static Widget getBody() {
    // Inicializar el controlador de notificaciones
    if (!Get.isRegistered<NotificationsController>()) {
      Get.put(NotificationsController());
    }

    return Builder(
      builder: (context) => ListView(
        children: [
          const SizedBox(height: 16),
          getSeparator('Preferencias'),
          Obx(() => getSwitchListTile(
            'Notificaciones',
            NotificationsController.to.notificationsEnabled,
            (bool value) => NotificationsController.to.toggleNotifications(),
          )),
          getListTile('Cambiar la fuente', Icons.text_fields, () {}),
          getListTile(
            'Tema',
            Icons.brightness_6,
            () async {
              await ThemeController.to.toggleTheme();
              Get.forceAppUpdate();
            },
          ),
          getListTile('Idiomas', Icons.language, () {}),

          const Divider(),

          getSeparator('Soporte'),
          getListTile(
            'Política de privacidad',
            Icons.privacy_tip_outlined,
            () {},
          ),
          getListTile('Ayuda', Icons.help_outline, () {}),
          getListTile(
            'Contacto con servicio técnico',
            Icons.support_agent,
            () {},
          ),

          const Divider(),

          getSeparator('Acerca de'),
          getListTile(
            'Versión de la app',
            Icons.info_outline,
            () {},
            subtitle: '1.0.0',
          ),

          const Divider(),

          getListTile('Cerrar sesión', Icons.logout, () => _logout(context), isDestructive: true),
        ],
      ),
    );
  }

  static Widget getListTile(
    String text,
    IconData icon,
    VoidCallback onTap, {
    String? subtitle,
    bool isDestructive = false,
  }) {
    return Builder(
      builder: (context) => ListTile(
        leading: Icon(icon, color: isDestructive ? Colors.red : null),
        title: Text(
          text,
          style: isDestructive ? const TextStyle(color: Colors.red) : null,
        ),
        subtitle: subtitle != null ? Text(subtitle) : null,
        onTap: () {
          if (text == 'Cerrar sesión') {
            _logout(context);
          } else {
            onTap();
          }
        },
      ),
    );
  }

  static Widget getSeparator(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  static Widget getSwitchListTile(String text, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(text),
      value: value,
      onChanged: onChanged,
      activeColor: ThemeController.to.getButtonBlue(),
      activeTrackColor: ThemeController.to.getLightBlue(),
      inactiveThumbColor: ThemeController.to.getGrey(),
      inactiveTrackColor: ThemeController.to.getLightGrey(),
    );
  }
}
