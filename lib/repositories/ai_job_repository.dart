import '../services/ai_job_lifecycle.dart';

/// Persistence interface for AI job snapshots.
abstract class AiJobRepository {
  Future<void> insert(AiJobSnapshot snapshot);
  Future<void> update(AiJobSnapshot snapshot);
  Future<AiJobSnapshot?> findById(String id);
  Future<List<AiJobSnapshot>> findByStatus(AiJobStatus status);
  Future<List<AiJobSnapshot>> findAll();

  /// Find jobs that were interrupted (queued or running) and can be resumed.
  Future<List<AiJobSnapshot>> findResumable();

  Future<void> delete(String id);
}
