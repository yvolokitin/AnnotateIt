import 'dart:async';
import 'package:sqflite/sqflite.dart';

import 'project_database.dart';
import '../models/user.dart';

class UserDatabase {
  static final UserDatabase instance = UserDatabase._init();

  UserDatabase._init();

  Future<Database> get database async => await ProjectDatabase.instance.database;

  Future<User> create(User user) async {
    final db = await database;
    final id = await db.insert('users', user.toMap());
    return user.copyWith(id: id);
  }

  Future<User?> getUser() async {
    final db = await database;

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
    final db = await database;
    return db.update(
      'users',
      user.toMap(),
      where: 'id = ?',
      whereArgs: [user.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await database;
    await db.close();
  }
}
