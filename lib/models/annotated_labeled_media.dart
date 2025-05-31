import 'media_item.dart';
import 'annotation.dart';
import 'label.dart';

class AnnotatedLabeledMedia {
  final MediaItem mediaItem;
  final List<Annotation> annotations;
  final List<Label> labels;

  AnnotatedLabeledMedia({
    required this.mediaItem,
    required this.annotations,
    required this.labels,
  });

  /// Returns true if any annotations are associated with this media.
  bool get hasAnnotations => annotations.isNotEmpty;

  /// Returns true if any labels are associated (e.g., classification).
  bool get hasLabels => labels.isNotEmpty;

  /// Returns a short human-readable label summary.
  String get labelSummary => labels.map((l) => l.name).join(', ');

  /// Returns annotation count.
  int get annotationCount => annotations.length;

  /// Find label by ID.
  Label? findLabelById(int? labelId) {
    for (final label in labels) {
      if (label.id == labelId) return label;
    }
    return null;
  }

  /// Get all annotations for a given label ID.
  List<Annotation> getAnnotationsByLabelId(String labelId) {
    return annotations.where((a) => a.labelId == labelId).toList();
  }

  /// Returns the label name for a given annotation.
  /// Returns null if no matching label is found.
  String? getLabelNameForAnnotation(Annotation annotation) {
    final label = findLabelById(annotation.labelId);
    return label?.name;
  }

  /// Check if this item contains a specific label.
  bool containsLabel(String labelId) {
    return labels.any((label) => label.id == labelId);
  }

  /// Returns the list of unique label IDs referenced in annotations.
  Set<int> get referencedLabelIds {
    return annotations
      .map((a) => a.labelId)
      .whereType<int>() // filters out nulls
      .toSet();
  }

  /// Checks if a given user is the last annotator.
  bool wasAnnotatedBy(int userId) {
    return mediaItem.lastAnnotator == userId;
  }

  /// Deep copy
  AnnotatedLabeledMedia copyWith({
    MediaItem? mediaItem,
    List<Annotation>? annotations,
    List<Label>? labels,
  }) {
    return AnnotatedLabeledMedia(
      mediaItem: mediaItem ?? this.mediaItem,
      annotations: annotations ?? this.annotations,
      labels: labels ?? this.labels,
    );
  }

  @override
  String toString() {
    return 'AnnotatedLabeledMedia(mediaItem=${mediaItem.filePath}, annotations=$annotationCount, labels=${labels.length})';
  }
}
