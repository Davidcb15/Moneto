import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/hobby.dart';

class DatabaseHelper {
  //Inicializar la base de datos
  static final DatabaseHelper instance = DatabaseHelper._init();

  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('hobbies.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }
  // Creación tablas
  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE hobbies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        isSelected INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        hobby TEXT NOT NULL,
        amount REAL NOT NULL,
        description TEXT NOT NULL,
        date TEXT NOT NULL
      )
    ''');

  }
  // Obtener hobbies de la lista de preferencias
  Future<List<Hobby>> getHobbies() async {
    final db = await instance.database;
    final result = await db.query('hobbies');
    return result.map((json) => Hobby.fromMap(json)).toList();
  }
  //Insertar/Guardar hobbies
  Future<void> insertHobby(Hobby hobby) async {
    final db = await instance.database;
    await db.insert('hobbies', hobby.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }
  // Borrar hobbies
  Future<void> deleteAllHobbies() async {
    final db = await instance.database;
    await db.delete('hobbies');
  }
  // Mostrar los hobbies guardados por el usuario
  Future<void> insertExpense(String hobbyName, String description, double amount, String date) async {
    final db = await instance.database;
    await db.insert('expenses', {
      'hobby': hobbyName,
      'description': description,
      'amount': amount,
      'date': date
    });
  }
  // Actualizar hobbies con los datos introducidos
  Future<void> updateExpense(int id, String description, double amount, String date) async {
    final db = await instance.database;
    await db.update(
      'expenses',
      {
        'description': description,
        'amount': amount,
        'date': date,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
  //BOrrar los datos
  Future<void> deleteExpense(int id) async {
    final db = await instance.database;
    await db.delete('expenses', where: 'id = ?', whereArgs: [id]);
  }
  // OBtener total gastado por hobby
  Future<double> getTotalSpentForHobby(String hobbyName) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(amount) as total FROM expenses WHERE hobby = ?',
      [hobbyName],
    );

    if (result.isNotEmpty && result.first['total'] != null) {
      return (result.first['total'] as num).toDouble();
    } else {
      return 0.0;
    }
  }
  Future<List<Map<String, dynamic>>> getExpensesForHobby(String hobbyName) async {
    final db = await instance.database;
    return await db.query(
      'expenses',
      where: 'hobby = ?',
      whereArgs: [hobbyName],
      orderBy: 'date DESC',
    );
  }


}
