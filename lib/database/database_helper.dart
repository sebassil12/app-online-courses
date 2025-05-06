import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static const _databaseName = 'academy_database.db';
  static const _databaseVersion = 2; // Incrementado por el cambio de esquema

  // Tabla de usuarios
  static const usersTable = 'users';
  static const columnUserId = 'user_id';
  static const columnUsername = 'username';
  static const columnPassword = 'password';

  // Tabla de estudiantes
  static const studentsTable = 'students';
  static const columnStudentId = 'student_id';
  static const columnDate = 'date';
  static const columnCountry = 'country';
  static const columnCity = 'city';
  static const columnCourseValue = 'course_value';
  static const columnInitialFee = 'initial_fee';
  static const columnMonthlyFee = 'monthly_fee';
  static const columnUserRef = 'user_id'; // Clave foránea

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Crear tabla de usuarios
    await db.execute('''
      CREATE TABLE $usersTable (
        $columnUserId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnUsername TEXT UNIQUE NOT NULL,
        $columnPassword TEXT NOT NULL
      )
    ''');

    // Crear tabla de estudiantes
    await db.execute('''
      CREATE TABLE $studentsTable (
        $columnStudentId INTEGER PRIMARY KEY AUTOINCREMENT,
        $columnDate TEXT,
        $columnCountry TEXT,
        $columnCity TEXT,
        $columnCourseValue REAL,
        $columnInitialFee REAL,
        $columnMonthlyFee REAL,
        $columnUserRef INTEGER NOT NULL,
        FOREIGN KEY ($columnUserRef) REFERENCES $usersTable($columnUserId)
      )
    ''');

    // Insertar usuario admin por defecto
    await db.insert(usersTable, {
      columnUsername: 'admin',
      columnPassword: '1234',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $usersTable (
          $columnUserId INTEGER PRIMARY KEY AUTOINCREMENT,
          $columnUsername TEXT UNIQUE NOT NULL,
          $columnPassword TEXT NOT NULL
        )
      ''');
      
      await db.execute('''
        INSERT INTO $usersTable ($columnUsername, $columnPassword)
        VALUES ('admin', '1234')
      ''');
      
      await db.execute('''
        ALTER TABLE $studentsTable ADD COLUMN $columnUserRef INTEGER NOT NULL DEFAULT 1
      ''');
    }
  }

  // Operaciones para usuarios
  Future<int> insertUser(String username, String password) async {
    final db = await instance.database;
    return await db.insert(usersTable, {
      columnUsername: username,
      columnPassword: password,
    });
  }

  Future<Map<String, dynamic>?> getUser(String username, String password) async {
    final db = await instance.database;
    final result = await db.query(
      usersTable,
      where: '$columnUsername = ? AND $columnPassword = ?',
      whereArgs: [username, password],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<bool> usernameExists(String username) async {
    final db = await instance.database;
    final result = await db.query(
      usersTable,
      where: '$columnUsername = ?',
      whereArgs: [username],
      limit: 1,
    );
    return result.isNotEmpty;
  }

  // Operaciones para estudiantes
  Future<int> insertStudent(Map<String, dynamic> student) async {
    final db = await instance.database;
    return await db.insert(studentsTable, student);
  }

  Future<List<Map<String, dynamic>>> getStudentsByUser(int userId) async {
    final db = await instance.database;
    return await db.query(
      studentsTable,
      where: '$columnUserRef = ?',
      whereArgs: [userId],
    );
  }

  Future<Map<String, dynamic>?> getLatestStudentByUser(int userId) async {
    final db = await instance.database;
    final result = await db.query(
      studentsTable,
      where: '$columnUserRef = ?',
      whereArgs: [userId],
      orderBy: '$columnStudentId DESC',
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> close() async {
    final db = await instance.database;
    await db.close();
  }
}