import '../models/annotation.dart';

abstract class AnnotationRepository {
  Future<int> insertAnnotation(Annotation annotation);
  Future<void> insertAnnotationsBatch(List<Annotation> annotations);
  Future<List<Annotation>> fetchAnnotations(int mediaItemId, {String? type});
  Future<int> updateAnnotation(Annotation annotation);
  Future<int> transitionReviewStatus({
    required int annotationId,
    required int expectedVersion,
    required String nextStatus,
    int? reviewerId,
    String? reviewComment,
  });
  Future<int> deleteAnnotation(int annotationId);
  Future<void> deleteAnnotationsByMedia(int mediaItemId);
  Future<int> deleteAnnotationsByMediaAndType(
    int mediaItemId,
    String annotationType,
  );
}
