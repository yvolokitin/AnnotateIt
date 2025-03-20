class Project {
  final int? id;
  final String name;
  final String type;
  final String icon;
  final DateTime creationDate;
  final DateTime lastUpdated; 
  final List<String> labels;
  final List<String> labelColors;

  Project({
    this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.creationDate,
    required this.lastUpdated,
    required this.labels,
    required this.labelColors,
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
    };
  }

  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      icon: map['icon'],
      creationDate: DateTime.parse(map['creationDate']),
      lastUpdated: DateTime.parse(map['lastUpdated']),
      labels: map['labels'].split(','), // Convert back to list
      labelColors: (map['labelColors'] as String).isEmpty 
          ? List.filled((map['labels'] as String).split(',').length, "#FFFFFF") // Default white
          : (map['labelColors'] as String).split(','),
    );
  }
}
