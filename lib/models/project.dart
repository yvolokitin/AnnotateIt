class Project {
  final int? id;
  final String name;
  final String type;
  final String icon;
  final DateTime creationDate;
  final DateTime lastUpdated; 
  final List<String> labels;
  final List<String> labelColors;
  final String? defaultDatasetId; // link to default dataset

  Project({
    this.id,
    required this.name,
    required this.type,
    this.icon = 'assets/images/default_project_image.svg',
    required this.creationDate,
    required this.lastUpdated,
    required this.labels,
    required this.labelColors,
    this.defaultDatasetId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'creationDate': creationDate.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'labels': labels.join(','), // Store as comma-separated string
      'labelColors': labelColors.join(','), // Store as comma-separated string hex values (#FF5733,#33FF57,...)
      'defaultDatasetId': defaultDatasetId,
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'] ?? 'assets/images/default_project_image.svg',
      creationDate: DateTime.parse(map['creationDate']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      labels: map['labels'].split(','), // Convert back to list
      labelColors: (map['labelColors'] as String).isEmpty 
          ? List.filled((map['labels'] as String).split(',').length, "#FFFFFF") // Default white
          : (map['labelColors'] as String).split(','),
      defaultDatasetId: map['defaultDatasetId'],
    );
  }

  // Feature: If need to copy Project object from existed one, and only need to changethe defaultDatasetId
  Project copyWith({
    int? id,
    String? name,
    String? type,
    String? icon,
    DateTime? creationDate,
    DateTime? lastUpdated,
    List<String>? labels,
    List<String>? labelColors,
    String? defaultDatasetId,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      creationDate: creationDate ?? this.creationDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      labels: labels ?? this.labels,
      labelColors: labelColors ?? this.labelColors,
      defaultDatasetId: defaultDatasetId ?? this.defaultDatasetId,
    );
  }

}
