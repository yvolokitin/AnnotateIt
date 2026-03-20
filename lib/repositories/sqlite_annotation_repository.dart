import '../data/annotation_database.dart';
import '../models/annotation.dart';
import 'annotation_repository.dart';

class SqliteAnnotationRepository implements AnnotationRepository {
  const SqliteAnnotationRepository();

  @override
  Future<int> insertAnnotation(Annotation annotation) {
    return AnnotationDatabase.instance.insertAnnotation(annotation);
  }

  @override
  Future<void> insertAnnotationsBatch(List<Annotation> annotations) {
    return AnnotationDatabase.instance.insertAnnotationsBatch(annotations);
  }

  @override
  Future<List<Annotation>> fetchAnnotations(int mediaItemId, {String? type}) {
    return AnnotationDatabase.instance.fetchAnnotations(
      mediaItemId,
      type: type,
    );
  }

  @override
  Future<int> updateAnnotation(Annotation annotation) {
    return AnnotationDatabase.instance.updateAnnotation(annotation);
  }

  @override
  Future<int> transitionReviewStatus({
    required int annotationId,
    required int expectedVersion,
    required String nextStatus,
    int? reviewerId,
    String? reviewComment,
  }) {
    return AnnotationDatabase.instance.transitionReviewStatus(
      annotationId: annotationId,
      expectedVersion: expectedVersion,
      nextStatus: nextStatus,
      reviewerId: reviewerId,
      reviewComment: reviewComment,
    );
  }

  @override
  Future<int> deleteAnnotation(int annotationId) {
    return AnnotationDatabase.instance.deleteAnnotation(annotationId);
  }

  @override
  Future<void> deleteAnnotationsByMedia(int mediaItemId) {
    return AnnotationDatabase.instance.deleteAnnotationsByMedia(mediaItemId);
  }

  @override
  Future<int> deleteAnnotationsByMediaAndType(
    int mediaItemId,
    String annotationType,
  ) {
    return AnnotationDatabase.instance.deleteAnnotationsByMediaAndType(
      mediaItemId,
      annotationType,
    );
  }
}
