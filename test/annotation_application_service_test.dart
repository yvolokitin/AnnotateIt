import 'package:flutter_test/flutter_test.dart';

import 'package:annotateit/models/annotation.dart';
import 'package:annotateit/models/label.dart';
import 'package:annotateit/repositories/annotation_repository.dart';
import 'package:annotateit/services/annotation_application_service.dart';

class _InMemoryAnnotationRepository implements AnnotationRepository {
  final Map<int, Annotation> _annotations = <int, Annotation>{};
  int _nextId = 1;

  @override
  Future<int> insertAnnotation(Annotation annotation) async {
    final id = _nextId++;
    _annotations[id] =
        Annotation(
            id: id,
            mediaItemId: annotation.mediaItemId,
            labelId: annotation.labelId,
            annotationType: annotation.annotationType,
            data: annotation.data,
            confidence: annotation.confidence,
            annotatorId: annotation.annotatorId,
            comment: annotation.comment,
            status: annotation.status,
            version: annotation.version,
            createdAt: annotation.createdAt,
            updatedAt: annotation.updatedAt,
          )
          ..name = annotation.name
          ..color = annotation.color;
    return id;
  }

  @override
  Future<void> insertAnnotationsBatch(List<Annotation> annotations) async {
    for (final annotation in annotations) {
      await insertAnnotation(annotation);
    }
  }

  @override
  Future<List<Annotation>> fetchAnnotations(
    int mediaItemId, {
    String? type,
  }) async {
    return _annotations.values
        .where(
          (a) =>
              a.mediaItemId == mediaItemId &&
              (type == null || a.annotationType == type),
        )
        .toList();
  }

  @override
  Future<int> updateAnnotation(Annotation annotation) async {
    final existing = _annotations[annotation.id];
    if (existing == null) return 0;
    if (existing.version != annotation.version) return 0;
    _annotations[annotation.id!] =
        Annotation(
            id: annotation.id,
            mediaItemId: annotation.mediaItemId,
            labelId: annotation.labelId,
            annotationType: annotation.annotationType,
            data: annotation.data,
            confidence: annotation.confidence,
            annotatorId: annotation.annotatorId,
            comment: annotation.comment,
            status: annotation.status,
            version: annotation.version + 1,
            createdAt: annotation.createdAt,
            updatedAt: DateTime.now(),
          )
          ..name = annotation.name
          ..color = annotation.color;
    return 1;
  }

  @override
  Future<int> transitionReviewStatus({
    required int annotationId,
    required int expectedVersion,
    required String nextStatus,
    int? reviewerId,
    String? reviewComment,
  }) async {
    final existing = _annotations[annotationId];
    if (existing == null) return 0;
    if (existing.version != expectedVersion) return 0;
    _annotations[annotationId] = existing.copyWith(
      reviewStatus: nextStatus,
      reviewedBy: reviewerId,
      reviewedAt: DateTime.now(),
      reviewComment: reviewComment,
      version: expectedVersion + 1,
      updatedAt: DateTime.now(),
    );
    return 1;
  }

  @override
  Future<int> deleteAnnotation(int annotationId) async {
    return _annotations.remove(annotationId) == null ? 0 : 1;
  }

  @override
  Future<void> deleteAnnotationsByMedia(int mediaItemId) async {
    _annotations.removeWhere((_, value) => value.mediaItemId == mediaItemId);
  }

  @override
  Future<int> deleteAnnotationsByMediaAndType(
    int mediaItemId,
    String annotationType,
  ) async {
    final toDelete =
        _annotations.entries
            .where(
              (e) =>
                  e.value.mediaItemId == mediaItemId &&
                  e.value.annotationType == annotationType,
            )
            .map((e) => e.key)
            .toList();
    for (final id in toDelete) {
      _annotations.remove(id);
    }
    return toDelete.length;
  }
}

void main() {
  group('AnnotationApplicationService', () {
    test(
      'single-label assignment replaces only classification annotations',
      () async {
        final repo = _InMemoryAnnotationRepository();
        final service = AnnotationApplicationService(
          annotationRepository: repo,
        );
        final label = Label(
          id: 7,
          labelOrder: 0,
          projectId: 1,
          name: 'cat',
          color: '#ff0000',
        );

        final existing = <Annotation>[
          Annotation(
            id: 1,
            mediaItemId: 10,
            labelId: 5,
            annotationType: 'classification',
            data: const {},
            version: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          Annotation(
            id: 2,
            mediaItemId: 10,
            labelId: 3,
            annotationType: 'bbox',
            data: {'x': 1.0, 'y': 2.0, 'width': 3.0, 'height': 4.0},
            version: 1,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];
        await repo.insertAnnotationsBatch(existing);

        final result = await service.assignClassificationLabel(
          mediaItemId: 10,
          label: label,
          isMultiLabel: false,
          existingAnnotations: existing,
        );

        expect(result.changed, isTrue);
        expect(result.addedAnnotation, isNotNull);
        final types = result.annotations.map((a) => a.annotationType).toList();
        expect(types.where((t) => t == 'classification').length, 1);
        expect(types.where((t) => t == 'bbox').length, 1);
      },
    );

    test('multi-label assignment skips duplicate class annotation', () async {
      final repo = _InMemoryAnnotationRepository();
      final service = AnnotationApplicationService(annotationRepository: repo);
      final label = Label(
        id: 8,
        labelOrder: 0,
        projectId: 1,
        name: 'dog',
        color: '#00ff00',
      );
      final existing = <Annotation>[
        Annotation(
          id: 1,
          mediaItemId: 20,
          labelId: 8,
          annotationType: 'classification',
          data: const {},
          version: 1,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      ];

      final result = await service.assignClassificationLabel(
        mediaItemId: 20,
        label: label,
        isMultiLabel: true,
        existingAnnotations: existing,
      );

      expect(result.changed, isFalse);
      expect(result.annotations.length, 1);
    });

    test('update label reports conflict for stale version', () async {
      final repo = _InMemoryAnnotationRepository();
      final service = AnnotationApplicationService(annotationRepository: repo);
      final annotation = Annotation(
        mediaItemId: 30,
        labelId: 1,
        annotationType: 'bbox',
        data: {'x': 1.0, 'y': 1.0, 'width': 2.0, 'height': 2.0},
        version: 2,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final id = await repo.insertAnnotation(annotation);

      await repo.updateAnnotation(
        Annotation(
          id: id,
          mediaItemId: annotation.mediaItemId,
          labelId: annotation.labelId,
          annotationType: annotation.annotationType,
          data: annotation.data,
          version: annotation.version,
          createdAt: annotation.createdAt,
          updatedAt: annotation.updatedAt,
        ),
      );

      final stale = Annotation(
        id: id,
        mediaItemId: annotation.mediaItemId,
        labelId: annotation.labelId,
        annotationType: annotation.annotationType,
        data: annotation.data,
        version: annotation.version,
        createdAt: annotation.createdAt,
        updatedAt: annotation.updatedAt,
      );
      final newLabel = Label(
        id: 9,
        labelOrder: 0,
        projectId: 1,
        name: 'updated',
        color: '#0000ff',
      );

      final result = await service.updateAnnotationLabel(
        annotation: stale,
        newLabel: newLabel,
      );
      expect(result.status, AnnotationLabelUpdateStatus.conflict);
      expect(result.annotation, isNull);
    });
  });
}
