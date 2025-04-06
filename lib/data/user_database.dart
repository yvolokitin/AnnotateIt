import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/user.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();

  static Database? _database;

  UserDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDB('user.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        firstName TEXT NOT NULL,
        lastName TEXT NOT NULL,
        email TEXT NOT NULL,
        iconPath TEXT,
        datasetFolder TEXT,
        thumbnailFolder TEXT,
        themeMode TEXT NOT NULL,
        language TEXT NOT NULL,
        autoSave INTEGER NOT NULL,
        showTips INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    final now = DateTime.now().toIso8601String();
    await db.insert('users', {
      'firstName': 'Captain',
      'lastName': 'Annotator',
      'email': 'captain@labelship.local',
      'iconPath': '',
      'datasetFolder': '/storage/emulated/0/AnnotationApp/datasets',
      'thumbnailFolder': '/storage/emulated/0/AnnotationApp/thumbnails',
      'themeMode': 'dark',
      'language': 'en',
      'autoSave': 1,
      'showTips': 1,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  Future<User> create(User user) async {
    final db = await instance.database;

    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<User?> getUser() async {
    final db = await instance.database;

    final maps = await db.query(
      'users',
      columns: User.fields,
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<int> update(User user) async {
    final db = await instance.database;

    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await instance.database;

    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;

    db.close();
  }
}
