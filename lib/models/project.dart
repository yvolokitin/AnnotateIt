import 'label.dart';

class Project {
  final int? id;
  final String name;
  final String? description;
  final String type;
  final String icon;
  final DateTime creationDate;
  final DateTime lastUpdated; 
  final String? defaultDatasetId;
  final int ownerId;

  /// Labels are attached after fetching, not stored in DB
  List<Label>? labels;

  Project({
    this.id,
    required this.name,
    this.description,
    required this.type,
    this.icon = 'assets/images/default_project_image.svg',
    required this.creationDate,
    required this.lastUpdated,
    this.defaultDatasetId,
    required this.ownerId,
    this.labels, // optional field
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'type': type,
      'icon': icon,
      'creationDate': creationDate.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'defaultDatasetId': defaultDatasetId,
      'ownerId': ownerId,
      // Do not include labels here because they are stored in a separate table.
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      type: map['type'],
      icon: map['icon'] ?? 'assets/images/default_project_image.svg',
      creationDate: DateTime.parse(map['creationDate']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      defaultDatasetId: map['defaultDatasetId'],
      ownerId: map['ownerId'],
    );
  }

  Project copyWith({
    int? id,
    String? name,
    String? description,
    String? type,
    String? icon,
    DateTime? creationDate,
    DateTime? lastUpdated,
    String? defaultDatasetId,
    int? ownerId,
    List<Label>? labels,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      creationDate: creationDate ?? this.creationDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      defaultDatasetId: defaultDatasetId ?? this.defaultDatasetId,
      ownerId: ownerId ?? this.ownerId,
      labels: labels ?? this.labels,
    );
  }

  @override
  String toString() {
    final labelPreview = labels?.map((l) => l.name).join(', ') ?? 'None';
    return '''
      Project(
        id: $id,
        name: $name,
        description: $description,
        type: $type,
        icon: $icon,
        creationDate: $creationDate,
        lastUpdated: $lastUpdated,
        defaultDatasetId: $defaultDatasetId,
        ownerId: $ownerId,
        labels: [$labelPreview]
    )''';
  }
}
