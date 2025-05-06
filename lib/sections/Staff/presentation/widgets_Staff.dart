import 'package:flutter/material.dart';
import 'package:mi_hospital/main.dart';
import 'package:mi_hospital/sections/Staff/entities/StaffFirebase.dart';

class WidgetsStaff {
 Widget header() {
  return Padding(
    padding: const EdgeInsets.all(16.0),
    child: Row(
      children: [
        buscador(),
      ],
    ),
  );
}


 Widget body() {
  return FutureBuilder<Widget>(
    future: crearColumnConUsuarios(),  // Llamamos a la función que devuelve la columna
    builder: (context, snapshot) {
      // Verificamos el estado de la conexión
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Si los datos aún están cargando, mostramos un indicador de carga
        return Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        // Si hay un error, mostramos un mensaje de error
        return Center(child: Text('Error: ${snapshot.error}'));
      } else if (!snapshot.hasData || snapshot.data == null) {
        // Si no se encontraron datos, mostramos un mensaje de que no hay usuarios
        return Center(child: Text('No se encontraron usuarios.'));
      } else {
        // Cuando los datos estén listos, mostramos la columna con los usuarios
        return snapshot.data!;
      }
    },
  );
}


  Widget estadoCard(String nombre, bool estado, codigo ) {
  return Container(
    height: 60,
    margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
    padding: const EdgeInsets.symmetric(horizontal: 20),
    decoration: BoxDecoration(
      color: Colors.blue,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          nombre,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: estado ? Colors.green : Colors.red,
            shape: BoxShape.circle,
          ),
        ),
      ],
    ),
  );
}
Widget buscador() {
  return Expanded(
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar...',
              filled: true,
              fillColor: Color(0xFFF1F1F1), // gris claro
              contentPadding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade400),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.blue, width: 2),
              ),
            ),
            style: TextStyle(fontSize: 16),
          ),
      );
}

Future<Widget> crearColumnConUsuarios() async {
  List<Map> users = await StaffFirebase().getUsersWithSamePrefix(GetData().getHospitalCode());

  // Ordenamos la lista de usuarios, primero los que tienen 'estado' true
  users.sort((a, b) {
    bool estadoA = a['state'] ?? false;
    // ignore: unused_local_variable
    bool estadoB = b['state'] ?? false;
    return estadoA ? -1 : 1; // Primero los true, luego los false
  });

  // Creamos la lista de widgets a partir de los usuarios ordenados
  List<Widget> userCards = users.map((user) {
    String userName = user['name'] ?? 'Sin nombre';
    bool userStatus = user['state'] ?? false;
    var userCode = user['code']?? 'Sin código';

    return GestureDetector(
      onTap: () {
  
       
      },
      child: estadoCard(userName, userStatus, userCode), // Envuelves la tarjeta con GestureDetector
    );
  }).toList();

  return Column(
    children: userCards,
  );
}


}
