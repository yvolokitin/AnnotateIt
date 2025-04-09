import 'package:sqflite/sqflite.dart';
import '../models/annotation.dart';

class AnnotationDatabase {
  static final AnnotationDatabase instance = AnnotationDatabase._init();
  static Database? _db;

  AnnotationDatabase._init();

  void setDatabase(Database db) {
    _db = db;
  }

  Future<Database> get database async {
    if (_db != null) return _db!;
    throw Exception("Database not set.");
  }

  Future<void> insertAnnotation(Annotation annotation) async {
    final db = await database;
    await db.insert('annotations', annotation.toMap());
  }

  Future<List<Annotation>> fetchAnnotations(String mediaItemId) async {
    final db = await database;
    final result = await db.query('annotations', where: 'media_item_id = ?', whereArgs: [mediaItemId]);
    return result.map((map) => Annotation.fromMap(map)).toList();
  }
}
