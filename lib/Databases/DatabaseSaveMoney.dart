import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseSaveMoney {
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('save_money.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ahorros (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL
      )
    ''');
    // Insertar un registro inicial si no existe
    final List<Map<String, dynamic>> existing = await db.query('ahorros');
    if (existing.isEmpty) {
      await db.insert('ahorros', {'total': 0.0});
    }
  }

  // Obtiene el total de ahorros
  static Future<double> getTotalAhorros() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('ahorros');
    if (result.isNotEmpty) {
      return result.first['total'] as double;
    } else {
      return 0.0;
    }
  }

  // Inserta o actualiza el total de ahorros
  static Future<void> insertOrUpdateAhorro(double total) async {
    final db = await database;
    final List<Map<String, dynamic>> existing = await db.query('ahorros');
    if (existing.isNotEmpty) {
      await db.update('ahorros', {'total': total}, where: 'id = ?', whereArgs: [existing.first['id']]);
    } else {
      await db.insert('ahorros', {'total': total});
    }
  }
}