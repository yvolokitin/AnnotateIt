import 'dart:convert';

class Dataset {
  final String id;
  final int projectId;
  final String name;
  final String description;
  final String type; // detection, classification, segmentation, etc.
  final String source; // manual, imported, duplicated, etc.
  final String format; // coco, yolo, voc, etc.
  final String version;
  final int mediaCount;
  final int annotationCount;
  final bool defaultDataset;
  final String? license;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // List of MediaFolder IDs linked to this Dataset
  final List<int>? folders;

  Dataset({
    required this.id,
    required this.projectId,
    required this.name,
    required this.description,
    required this.type,
    required this.source,
    required this.format,
    required this.version,
    required this.mediaCount,
    required this.annotationCount,
    required this.defaultDataset,
    required this.createdAt,
    this.license,
    this.metadata,
    this.updatedAt,
    this.folders, 
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'projectId': projectId,
      'name': name,
      'description': description,
      'type': type,
      'source': source,
      'format': format,
      'version': version,
      'mediaCount': mediaCount,
      'annotationCount': annotationCount,
      'defaultDataset': defaultDataset ? 1 : 0,
      'license': license,
      'metadata': metadata != null ? metadata.toString() : null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory Dataset.fromMap(Map<String, dynamic> map) {
    return Dataset(
      id: map['id'],
      projectId: map['projectId'],
      name: map['name'],
      description: map['description'],
      type: map['type'],
      source: map['source'],
      format: map['format'],
      version: map['version'],
      mediaCount: map['mediaCount'],
      annotationCount: map['annotationCount'],
      defaultDataset: map['defaultDataset'] == 1,
      license: map['license'],
      metadata: map['metadata'] != null
          ? Map<String, dynamic>.from(_tryParseJson(map['metadata']))
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt:
          map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
    );
  }

  Dataset copyWith({
    String? id,
    int? projectId,
    String? name,
    String? description,
    String? type,
    String? source,
    String? format,
    String? version,
    int? mediaCount,
    int? annotationCount,
    bool? defaultDataset,
    String? license,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<int>? folders,
  }) {
    return Dataset(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      source: source ?? this.source,
      format: format ?? this.format,
      version: version ?? this.version,
      mediaCount: mediaCount ?? this.mediaCount,
      annotationCount: annotationCount ?? this.annotationCount,
      defaultDataset: defaultDataset ?? this.defaultDataset,
      license: license ?? this.license,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      folders: folders ?? this.folders,
    );
  }

  @override
  String toString() {
    return 'Dataset(\n'
      '  id: $id,\n'
      '  projectId: $projectId,\n'
      '  name: $name,\n'
      '  description: $description,\n'
      '  type: $type,\n'
      '  source: $source,\n'
      '  format: $format,\n'
      '  version: $version,\n'
      '  mediaCount: $mediaCount,\n'
      '  annotationCount: $annotationCount,\n'
      '  defaultDataset: $defaultDataset,\n'
      '  license: $license,\n'
      '  metadata: $metadata,\n'
      '  createdAt: $createdAt,\n'
      '  updatedAt: $updatedAt\n'
      '  folders: $folders\n'
      ')';
  }

  static dynamic _tryParseJson(String value) {
    try {
      return value.isNotEmpty ? jsonDecode(value) : {};
    } catch (_) {
      return {};
    }
  }
}
