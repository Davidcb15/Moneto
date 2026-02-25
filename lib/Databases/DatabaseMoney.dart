import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseMoney {
  static Database? _database;

  // Obtiene la instancia de la base de datos
  static Future<Database> get database async {
    if (_database != null) return _database!;

    // Inicializa la base de datos si aún no se ha hecho
    _database = await _initDB('money.db'); // Nombre de la base de datos: 'money.db'
    return _database!;
  }

  // Inicializa la base de datos
  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  // Crea la tabla para almacenar los ingresos
  static Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE Ingresos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        total REAL NOT NULL
      )
    ''');
    //await db.rawInsert('INSERT INTO Ingresos (total) VALUES (?)', [0.0]); // No es necesario insertar un valor inicial aquí
  }

  // Inserta o actualiza el total de ingresos
  static Future<void> insertOrUpdateIngreso(double total) async {
    final db = await database;
    final count = await db.query('Ingresos');

    if (count.isEmpty) {
      await db.insert('Ingresos', {'total': total});
    } else {
      await db.update('Ingresos', {'total': total}, where: 'id = 1'); // Actualiza el único registro
    }
  }

  // Obtiene el total de ingresos
  static Future<double> getTotalIngresos() async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query('Ingresos');
    if (result.isNotEmpty) {
      return result.first['total'] ?? 0.0;
    } else {
      return 0.0;
    }
  }
}

