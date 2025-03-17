class Project {
  final int? id;
  final String name;
  final String type;
  final String icon;
  final DateTime creationDate;
  final List<String> labels;

  Project({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.creationDate,
    required this.labels,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'creationDate': creationDate.toIso8601String(),
      'labels': labels.join(','), // Store as comma-separated string
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
      creationDate: DateTime.parse(map['creationDate']),
      labels: map['labels'].split(','), // Convert back to list
    );
  }
}
