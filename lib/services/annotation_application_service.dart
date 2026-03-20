import '../models/annotation.dart';
import '../models/label.dart';
import '../repositories/annotation_repository.dart';

class ClassificationAssignmentResult {
  final List<Annotation> annotations;
  final Annotation? addedAnnotation;
  final bool changed;

  const ClassificationAssignmentResult({
    required this.annotations,
    required this.addedAnnotation,
    required this.changed,
  });
}

enum AnnotationLabelUpdateStatus { updated, conflict }

class AnnotationLabelUpdateResult {
  final AnnotationLabelUpdateStatus status;
  final Annotation? annotation;

  const AnnotationLabelUpdateResult({required this.status, this.annotation});
}

class AnnotationApplicationService {
  final AnnotationRepository _annotationRepository;

  const AnnotationApplicationService({
    required AnnotationRepository annotationRepository,
  }) : _annotationRepository = annotationRepository;

  Future<ClassificationAssignmentResult> assignClassificationLabel({
    required int mediaItemId,
    required Label label,
    required bool isMultiLabel,
    required List<Annotation> existingAnnotations,
  }) async {
    if (isMultiLabel) {
      final exists = existingAnnotations.any(
        (a) => a.annotationType == 'classification' && a.labelId == label.id,
      );
      if (exists) {
        return ClassificationAssignmentResult(
          annotations: existingAnnotations,
          addedAnnotation: null,
          changed: false,
        );
      }
    } else {
      await _annotationRepository.deleteAnnotationsByMediaAndType(
        mediaItemId,
        'classification',
      );
    }

    final now = DateTime.now();
    final newAnnotation =
        Annotation(
            id: null,
            mediaItemId: mediaItemId,
            labelId: label.id,
            annotationType: 'classification',
            data: const {},
            confidence: 1.0,
            annotatorId: null,
            comment: null,
            status: 'pending',
            version: 1,
            createdAt: now,
            updatedAt: now,
          )
          ..name = label.name
          ..color = label.toColor();

    final insertedId = await _annotationRepository.insertAnnotation(
      newAnnotation,
    );
    final savedAnnotation =
        Annotation(
            id: insertedId,
            mediaItemId: newAnnotation.mediaItemId,
            labelId: newAnnotation.labelId,
            annotationType: newAnnotation.annotationType,
            data: newAnnotation.data,
            confidence: newAnnotation.confidence,
            annotatorId: newAnnotation.annotatorId,
            comment: newAnnotation.comment,
            status: newAnnotation.status,
            version: newAnnotation.version,
            createdAt: newAnnotation.createdAt,
            updatedAt: newAnnotation.updatedAt,
          )
          ..name = newAnnotation.name
          ..color = newAnnotation.color;

    final updated =
        isMultiLabel
            ? <Annotation>[...existingAnnotations, savedAnnotation]
            : <Annotation>[
              ...existingAnnotations.where(
                (a) => a.annotationType != 'classification',
              ),
              savedAnnotation,
            ];

    return ClassificationAssignmentResult(
      annotations: updated,
      addedAnnotation: savedAnnotation,
      changed: true,
    );
  }

  Future<AnnotationLabelUpdateResult> updateAnnotationLabel({
    required Annotation annotation,
    required Label newLabel,
  }) async {
    final updatedAnnotation = annotation.copyWith(
      labelId: newLabel.id,
      name: newLabel.name,
      color: newLabel.toColor(),
      updatedAt: DateTime.now(),
    );

    final updatedCount = await _annotationRepository.updateAnnotation(
      updatedAnnotation,
    );
    if (updatedCount == 0) {
      return const AnnotationLabelUpdateResult(
        status: AnnotationLabelUpdateStatus.conflict,
      );
    }

    return AnnotationLabelUpdateResult(
      status: AnnotationLabelUpdateStatus.updated,
      annotation: updatedAnnotation.copyWith(
        version: updatedAnnotation.version + 1,
      ),
    );
  }
}
