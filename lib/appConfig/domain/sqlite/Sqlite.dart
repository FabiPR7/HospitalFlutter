import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

// 1. Abrir/Crear la base de datos
class DatabaseHelper {

Future<Database> initDB() async {
  final databasePath = await getDatabasesPath();
  final path = join(databasePath, 'mi_db.db');
  
  return await openDatabase(
    path,
    version: 1,
    onCreate: (db, version) async {
      await db.execute('''
        CREATE TABLE usuario(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          nombre TEXT,
          hospital TEXT,
          codigo TEXT,
          rol TEXT
        )
      ''');
    },
  );
  
}
  Future<void> insertUserSQlite(String name, String email, String codigo) async {
    final db = await initDB();
    
    await db.insert('usuario', {
      'nombre': '${name}}',
      'codigo': '${codigo}',
      'rol': 'Medico',
      'hospital': 'Hospital General San Juan'
    });
    await db.close();
  }

  Future<Map<String, dynamic>?> getFirstUser() async {
  final db = await initDB();
  try {
    final List<Map<String, dynamic>> result = await db.query(
      'usuario',
      limit: 1  
    );
    
    return result.isNotEmpty ? result.first : null;
  } catch (e) {
    return null;
  } finally {
    await db.close();
  }
}

Future<String?> getUserName() async {
  final db = await DatabaseHelper().initDB();
  try {
    final List<Map<String, dynamic>> result = await db.query(
      'usuario',          
      columns: ['nombre'], 
      limit: 1,           
    );
    if (result.isNotEmpty) {
      return result.first['nombre'] as String?; 
    }
    return null; 
  } catch (e) {
    return null;
  } finally {
    await db.close(); 
  }
}

Future<String?> getUserCode() async {
  final db = await DatabaseHelper().initDB();
  try {
    final List<Map<String, dynamic>> result = await db.query(
      'usuario',          
      columns: ['codigo'], 
      limit: 1,           
    );
    if (result.isNotEmpty) {
      return result.first['codigo'] as String?; 
    }
    return null; 
  } catch (e) {
    return null;
  } finally {
    await db.close(); 
  }
}

Future<String?> getHospitalCode() async {
  try {
    String? userCode = await getUserCode();
    final parts = userCode?.split('-');
    
    if (parts!.isNotEmpty) {
      return parts.first; 
    }
    return null;
  } catch (e) {
    return null; 
  }
}


}

