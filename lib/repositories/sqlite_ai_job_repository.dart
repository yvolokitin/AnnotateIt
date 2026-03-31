import 'package:sqflite/sqflite.dart';

import '../services/ai_job_lifecycle.dart';
import 'ai_job_repository.dart';

class SqliteAiJobRepository implements AiJobRepository {
  final Database _db;

  const SqliteAiJobRepository(this._db);

  @override
  Future<void> insert(AiJobSnapshot snapshot) async {
    await _db.insert('ai_jobs', snapshot.toMap());
  }

  @override
  Future<void> update(AiJobSnapshot snapshot) async {
    await _db.update(
      'ai_jobs',
      snapshot.toMap(),
      where: 'id = ?',
      whereArgs: [snapshot.id],
    );
  }

  @override
  Future<AiJobSnapshot?> findById(String id) async {
    final rows = await _db.query(
      'ai_jobs',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isEmpty ? null : AiJobSnapshot.fromMap(rows.first);
  }

  @override
  Future<List<AiJobSnapshot>> findByStatus(AiJobStatus status) async {
    final rows = await _db.query(
      'ai_jobs',
      where: 'status = ?',
      whereArgs: [status.name],
      orderBy: 'created_at ASC',
    );
    return rows.map(AiJobSnapshot.fromMap).toList();
  }

  @override
  Future<List<AiJobSnapshot>> findAll() async {
    final rows = await _db.query('ai_jobs', orderBy: 'created_at ASC');
    return rows.map(AiJobSnapshot.fromMap).toList();
  }

  @override
  Future<List<AiJobSnapshot>> findResumable() async {
    final rows = await _db.query(
      'ai_jobs',
      where: 'status IN (?, ?)',
      whereArgs: [AiJobStatus.queued.name, AiJobStatus.running.name],
      orderBy: 'created_at ASC',
    );
    return rows.map(AiJobSnapshot.fromMap).toList();
  }

  @override
  Future<void> delete(String id) async {
    await _db.delete('ai_jobs', where: 'id = ?', whereArgs: [id]);
  }
}
