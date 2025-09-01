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

  /// Order of the project in the list (persisted as project_order in DB)
  final int order;

  /// Labels are attached after fetching, not stored in DB
  final List<Label> labels;

  Project({
    this.id,
    required this.name,
    this.description,
    required this.type,
    this.icon = 'assets/images/empty_project_folder.png',
    required this.creationDate,
    required this.lastUpdated,
    this.defaultDatasetId,
    required this.ownerId,
    this.order = 0,
    this.labels = const [], // default to empty list
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
      'project_order': order,
      // Do not include labels here because they are stored in a separate table.
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      type: map['type'],
      icon: map['icon'] ?? 'assets/images/empty_project_folder.png',
      creationDate: DateTime.parse(map['creationDate']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      defaultDatasetId: map['defaultDatasetId'],
      ownerId: map['ownerId'],
      order: map['project_order'] ?? 0,
      labels: const [], // always provide default empty list
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
    int? order,
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
      order: order ?? this.order,
      labels: labels ?? this.labels,
    );
  }

  @override
  String toString() {
    final labelPreview = labels.map((l) => l.name).join(', ');
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
        order: $order,
        labels: [$labelPreview]
    )''';
  }
}
