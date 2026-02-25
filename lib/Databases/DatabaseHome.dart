import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart'; // Importa intl para el formato de fechas


class DatabaseHome {
  static const _databaseName = "GastosBD.db";
  static const _databaseVersion = 2;

  // Nombre de la tabla
  static const tableGastos = 'gastos';

  // Nombres de las columnas
  static const columnId = 'id';
  static const columnCategory = 'category';
  static const columnDate = 'fecha';
  static const columnAmount = 'importe';

  // Singleton para asegurar una sola instancia de la base de datos
  DatabaseHome._privateConstructor();
  static final DatabaseHome instance = DatabaseHome._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializar la base de datos
  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

  // Crear la tabla gastos
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableGastos (
        $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnCategory TEXT NOT NULL,
        $columnDate TEXT NOT NULL,
        $columnAmount REAL NOT NULL
      )
      ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Ejemplo de cómo añadir una nueva columna. Adaptar según tus necesidades.
      await db.execute('ALTER TABLE $tableGastos ADD COLUMN nueva_columna INTEGER;');
    }
  }

  // Insertar un gasto en la base de datos o actualiza si ya existe
  Future<int> insertOrUpdateExpense(
      String category, double amount, DateTime date) async {
    final db = await database;
    final formattedDate = DateFormat('yyyy-MM-dd').format(
        date); // Formatea la fecha para la base de datos.
    Map<String, dynamic> row = {
      columnCategory: category,
      columnDate: formattedDate,
      columnAmount: amount,
    };
    // Primero, intenta actualizar el registro basado en la categoría y la fecha
    int updatedRows = await db.update(
      tableGastos,
      row,
      where: '$columnCategory = ? AND $columnDate = ?',
      whereArgs: [category, formattedDate],
    );
    // Si no se actualizó ningún registro, inserta uno nuevo
    if (updatedRows == 0) {
      return await db.insert(tableGastos, row);
    }
    return updatedRows; // Devuelve el número de filas actualizadas
  }

  // Obtener el total de gastos para una categoría
  Future<double> getTotalForCategory(String category) async {
    final db = await database;
    List<Map<String, dynamic>> result = await db.query(tableGastos,
        columns: ['SUM($columnAmount)'],
        where: '$columnCategory = ?',
        whereArgs: [category]);

    if (result.isNotEmpty && result.first.values.first != null) {
      return result.first.values.first as double;
    }
    return 0.0;
  }

  // Obtener todos los gastos para una categoría, ordenados por fecha
  Future<List<Map<String, dynamic>>> getGastosByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> result = await db.query(
      tableGastos,
      where: '$columnCategory = ?',
      whereArgs: [category],
      orderBy: '$columnDate DESC',
    );
    return result;
  }

  // Eliminar un gasto por su ID
  Future<int> deleteGasto(int id) async {
    final db = await database;
    return await db
        .delete(tableGastos, where: '$columnId = ?', whereArgs: [id]);
  }

  // Actualizar un gasto por su ID
  Future<int> updateGasto(int id, String fecha, double amount) async {
    final db = await database;
    final formattedDate =
    DateFormat('yyyy-MM-dd').format(DateTime.parse(fecha));
    Map<String, dynamic> row = {
      columnDate: formattedDate,
      columnAmount: amount,
    };
    return await db
        .update(tableGastos, row, where: '$columnId = ?', whereArgs: [id]);
  }
}
