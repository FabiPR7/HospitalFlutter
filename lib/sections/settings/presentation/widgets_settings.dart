import 'package:flutter/material.dart';

class WidgetsSettings {
  Widget getBody() {
    return ListView(
      children: [
        const SizedBox(height: 16),
        getSeparator('Preferencias'),
        getSwitchListTile('Notificaciones', true, (bool value) {}),
        getListTile('Cambiar la fuente', Icons.text_fields, () {}),
        getListTile('Tema', Icons.brightness_6, () {}),
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

        getListTile('Cerrar sesión', Icons.logout, () {}, isDestructive: true),
      ],
    );
  }

  Widget getListTile(
    String text,
    IconData icon,
    VoidCallback onTap, {
    String? subtitle,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(icon, color: isDestructive ? Colors.red : null),
      title: Text(
        text,
        style: isDestructive ? const TextStyle(color: Colors.red) : null,
      ),
      subtitle: subtitle != null ? Text(subtitle) : null,
      onTap: onTap,
    );
  }

  Widget getSeparator(String text) {
    return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            text,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        );
  }

  Widget getSwitchListTile(String text, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(text),
      value: value,
      onChanged: onChanged,
    );
  }
}
