class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String iconPath;
  final String datasetFolder;
  final String thumbnailFolder;
  final String themeMode;
  final String language;
  final bool autoSave;
  final bool showTips;
  final DateTime createdAt;
  final DateTime updatedAt;

  final bool? projectShowNoLabels;
  final bool? projectShowImportWarning;
  final bool? datasetEnableDuplicate;
  final bool? datasetEnableDelete;
  final bool? annotationAllowImageCopy;
  final double? annotationOpacity;

  static final List<String> fields = [
    'id',
    'firstName',
    'lastName',
    'email',
    'iconPath',
    'datasetFolder',
    'thumbnailFolder',
    'themeMode',
    'language',
    'autoSave',
    'showTips',
    'createdAt',
    'updatedAt',
    'projectShowNoLabels',
    'projectShowImportWarning',
    'datasetEnableDuplicate',
    'datasetEnableDelete',
    'annotationAllowImageCopy',
    'annotationOpacity',
  ];

  const User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.iconPath,
    required this.datasetFolder,
    required this.thumbnailFolder,
    required this.themeMode,
    required this.language,
    required this.autoSave,
    required this.showTips,
    required this.createdAt,
    required this.updatedAt,
    required this.projectShowNoLabels,
    required this.projectShowImportWarning,
    required this.datasetEnableDuplicate,
    required this.datasetEnableDelete,
    required this.annotationAllowImageCopy,
    required this.annotationOpacity,
  });

User copyWith({
  int? id,
  String? firstName,
  String? lastName,
  String? email,
  String? iconPath,
  String? datasetFolder,
  String? thumbnailFolder,
  String? themeMode,
  String? language,
  bool? autoSave,
  bool? showTips,
  DateTime? createdAt,
  DateTime? updatedAt,
  bool? projectShowNoLabels,
  bool? projectShowImportWarning,
  bool? datasetEnableDuplicate,
  bool? datasetEnableDelete,
  bool? annotationAllowImageCopy,
  double? annotationOpacity,
}) {
  return User(
    id: id ?? this.id,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email ?? this.email,
    iconPath: iconPath ?? this.iconPath,
    datasetFolder: datasetFolder ?? this.datasetFolder,
    thumbnailFolder: thumbnailFolder ?? this.thumbnailFolder,
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
    autoSave: autoSave ?? this.autoSave,
    showTips: showTips ?? this.showTips,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    projectShowNoLabels: projectShowNoLabels ?? this.projectShowNoLabels,
    projectShowImportWarning: projectShowImportWarning ?? this.projectShowImportWarning,
    datasetEnableDuplicate: datasetEnableDuplicate ?? this.datasetEnableDuplicate,
    datasetEnableDelete: datasetEnableDelete ?? this.datasetEnableDelete,
    annotationAllowImageCopy: annotationAllowImageCopy ?? this.annotationAllowImageCopy,
    annotationOpacity: annotationOpacity ?? this.annotationOpacity,
  );
}

  Map<String, dynamic> toMap() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'iconPath': iconPath,
        'datasetFolder': datasetFolder,
        'thumbnailFolder': thumbnailFolder,
        'themeMode': themeMode,
        'language': language,
        'autoSave': autoSave ? 1 : 0,
        'showTips': showTips ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),

        'projectShowNoLabels': projectShowNoLabels == true ? 1 : 0,
        'projectShowImportWarning': projectShowImportWarning == true ? 1 : 0,
        'datasetEnableDuplicate': datasetEnableDuplicate == true ? 1 : 0,
        'datasetEnableDelete': datasetEnableDelete == true ? 1 : 0,
        'annotationAllowImageCopy': annotationAllowImageCopy == true ? 1 : 0,
        'annotationOpacity': annotationOpacity ?? 0.35,

  };

  static User fromMap(Map<String, dynamic> map) => User(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      email: map['email'],
      iconPath: map['iconPath'],
      datasetFolder: map['datasetFolder'],
      thumbnailFolder: map['thumbnailFolder'],
      themeMode: map['themeMode'],
      language: map['language'],
      autoSave: map['autoSave'] == 1,
      showTips: map['showTips'] == 1,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
      projectShowNoLabels: map['projectShowNoLabels'] == 1,
      projectShowImportWarning: map['projectShowImportWarning'] == 1,
      datasetEnableDuplicate: map['datasetEnableDuplicate'] == 1,
      datasetEnableDelete: map['datasetEnableDelete'] == 1,
      annotationAllowImageCopy: map['annotationAllowImageCopy'] == 1,
      annotationOpacity: (map['annotationOpacity'] as num?)?.toDouble() ?? 0.35,

  );

  @override String toString() {
    return 'User($firstName $lastName, email: $email, theme: $themeMode, autosave: $autoSave)';
  }
}
