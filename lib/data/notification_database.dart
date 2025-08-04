import 'dart:async';
import 'package:sqflite/sqflite.dart';

import '../models/notification.dart';

class NotificationDatabase {
  static final NotificationDatabase instance = NotificationDatabase._init();
  static Database? _db;

  NotificationDatabase._init();

  void setDatabase(Database db) {
    _db = db;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    throw Exception("Database not set.");
  }
  
  Future<Notification> create(Notification notification) async {
    final db = await database;
    final id = await db.insert('notifications', notification.toMap());
    return notification.copyWith(id: id);
  }

  Future<List<Notification>> getAll({
    int? limit,
    int? offset,
    bool? isRead,
  }) async {
    final db = await database;
    
    String? where;
    List<dynamic>? whereArgs;
    
    if (isRead != null) {
      where = 'isRead = ?';
      whereArgs = [isRead ? 1 : 0];
    }

    final maps = await db.query(
      'notifications',
      columns: Notification.fields,
      where: where,
      whereArgs: whereArgs,
      orderBy: 'createdAt DESC',
      limit: limit,
      offset: offset,
    );

    return maps.map((map) => Notification.fromMap(map)).toList();
  }

  Future<int> getCount({bool? isRead}) async {
    final db = await database;
    
    String? where;
    List<dynamic>? whereArgs;
    
    if (isRead != null) {
      where = 'isRead = ?';
      whereArgs = [isRead ? 1 : 0];
    }

    final result = await db.query(
      'notifications',
      columns: ['COUNT(*) as count'],
      where: where,
      whereArgs: whereArgs,
    );

    return result.first['count'] as int;
  }

  Future<int> getUnreadCount() async {
    return await getCount(isRead: false);
  }

  Future<Notification?> getById(int id) async {
    final db = await database;
    final maps = await db.query(
      'notifications', 
      where: 'id = ?', 
      whereArgs: [id], 
      limit: 1
    );
    
    if (maps.isNotEmpty) {
      return Notification.fromMap(maps.first);
    }
    return null;
  }

  Future<int> markAsRead(int id) async {
    final db = await database;
    return db.update(
      'notifications',
      {'isRead': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markAllAsRead() async {
    final db = await database;
    return db.update(
      'notifications',
      {'isRead': 1},
      where: 'isRead = ?',
      whereArgs: [0],
    );
  }

  Future<int> update(Notification notification) async {
    final db = await database;
    return db.update(
      'notifications',
      notification.toMap(),
      where: 'id = ?',
      whereArgs: [notification.id],
    );
  }

  Future<int> delete(int id) async {
    final db = await database;
    return await db.delete(
      'notifications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteAll() async {
    final db = await database;
    return await db.delete('notifications');
  }

  Future<int> deleteOldNotifications({int daysToKeep = 30}) async {
    final db = await database;
    final cutoffDate = DateTime.now().subtract(Duration(days: daysToKeep));
    return await db.delete(
      'notifications',
      where: 'createdAt < ?',
      whereArgs: [cutoffDate.toIso8601String()],
    );
  }

  Future close() async {
    final db = await database;
    await db.close();
  }
}