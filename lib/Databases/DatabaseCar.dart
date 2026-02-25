import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseCar {
  static Database? _db;
  //Inicialización de la base de datos
  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'car_expenses.db');
    // Creación de la tabla
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(''' 
          CREATE TABLE gastos (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            categoria TEXT,
            fecha TEXT,  -- Guardamos la fecha como texto (formato yyyy-MM-dd)
            importe REAL
          )
        ''');
      },
    );
  }

  // Insertar gasto
  static Future<void> insertGasto(String categoria, String fecha, double importe) async {
    final db = await database;
    await db.insert('gastos', {
      'categoria': categoria,
      'fecha': fecha,  // Fecha en formato yyyy-MM-dd
      'importe': importe,
    });
  }

  // Obtener todos los gastos de una categoría
  static Future<List<Map<String, dynamic>>> getGastos(String categoria) async {
    final db = await database;
    return await db.query(
      'gastos',
      where: 'categoria = ?',
      whereArgs: [categoria],
    );
  }

  // Obtener el total de una categoría
  static Future<double> getTotal(String categoria) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(importe) as total FROM gastos WHERE categoria = ?',
      [categoria],
    );
    return result.first['total'] != null ? result.first['total'] as double : 0.0;
  }

  // Eliminar gasto por ID
  static Future<void> deleteGasto(int id) async {
    final db = await database;
    await db.delete(
      'gastos',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Actualizar gasto
  static Future<void> updateGasto(int id, String fecha, double importe) async {
    final db = await database;
    await db.update(
      'gastos',
      {
        'fecha': fecha,  // Actualizamos la fecha con el nuevo valor (formato yyyy-MM-dd)
        'importe': importe,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Método adicional para convertir fecha en formato String a DateTime (cuando sea necesario)
  static DateTime parseDate(String dateString) {
    return DateTime.parse(dateString);  // Convierte el String "yyyy-MM-dd" a DateTime
  }
}
