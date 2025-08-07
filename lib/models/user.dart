class User {
  final int? id;
  final String firstName;
  final String lastName;
  final String email;
  final String iconPath;
  final String datasetImportFolder;
  final String datasetExportFolder;
  final String thumbnailFolder;
  final String themeMode;
  final String language;
  final bool autoSave;
  final bool showTips;
  final DateTime createdAt;
  final DateTime updatedAt;

  final bool projectShowNoLabels;
  final bool datasetEnableDuplicate;
  final bool datasetEnableDelete;
  final bool labelsSetFirstAsDefault;
  final bool labelsDeleteAnnotations;
  final bool projectSkipDeleteConfirm;
  final bool projectShowImportWarning;
  final bool annotationAllowImageCopy;
  final bool askConfirmationOnAnnotationRemoval;
  final bool showExportLabelsButton;
  final bool autoSaveAnnotations;
  final double annotationOpacity;

  static final List<String> fields = [
    'id',
    'firstName',
    'lastName',
    'email',
    'iconPath',
    'datasetImportFolder',
    'datasetExportFolder',
    'thumbnailFolder',
    'themeMode',
    'language',
    'autoSave',
    'showTips',
    'createdAt',
    'updatedAt',
    'autoSaveAnnotations',
    'labelsDeleteAnnotations',
    'labelsSetFirstAsDefault',
    'projectSkipDeleteConfirm',
    'projectShowNoLabels',
    'projectShowImportWarning',
    'datasetEnableDuplicate',
    'datasetEnableDelete',
    'annotationAllowImageCopy',
    'askConfirmationOnAnnotationRemoval',
    'showExportLabelsButton',
    'annotationOpacity',
  ];

  const User({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.iconPath,
    required this.datasetImportFolder,
    required this.datasetExportFolder,
    required this.thumbnailFolder,
    required this.themeMode,
    required this.language,
    required this.autoSave,
    required this.showTips,
    required this.createdAt,
    required this.updatedAt,
    required this.autoSaveAnnotations,
    required this.labelsDeleteAnnotations,
    required this.labelsSetFirstAsDefault,
    required this.projectSkipDeleteConfirm,
    required this.projectShowNoLabels,
    required this.projectShowImportWarning,
    required this.datasetEnableDuplicate,
    required this.datasetEnableDelete,
    required this.annotationAllowImageCopy,
    required this.askConfirmationOnAnnotationRemoval,
    required this.showExportLabelsButton,
    required this.annotationOpacity,
  });

  User copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? email,
    String? iconPath,
    String? datasetImportFolder,
    String? datasetExportFolder,
    String? thumbnailFolder,
    String? themeMode,
    String? language,
    bool? autoSave,
    bool? showTips,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? autoSaveAnnotations,
    bool? labelsDeleteAnnotations,
    bool? labelsSetFirstAsDefault,
    bool? projectSkipDeleteConfirm,
    bool? projectShowNoLabels,
    bool? projectShowImportWarning,
    bool? datasetEnableDuplicate,
    bool? datasetEnableDelete,
    bool? annotationAllowImageCopy,
    bool? askConfirmationOnAnnotationRemoval,
    bool? showExportLabelsButton,
    double? annotationOpacity,
  }) {
    return User(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      iconPath: iconPath ?? this.iconPath,
      datasetImportFolder: datasetImportFolder ?? this.datasetImportFolder,
      datasetExportFolder: datasetExportFolder ?? this.datasetExportFolder,
      thumbnailFolder: thumbnailFolder ?? this.thumbnailFolder,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      autoSave: autoSave ?? this.autoSave,
      showTips: showTips ?? this.showTips,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      autoSaveAnnotations: autoSaveAnnotations ?? this.autoSaveAnnotations,
      labelsDeleteAnnotations: labelsDeleteAnnotations ?? this.labelsDeleteAnnotations,
      labelsSetFirstAsDefault: labelsSetFirstAsDefault ?? this.labelsSetFirstAsDefault,
      projectSkipDeleteConfirm: projectSkipDeleteConfirm ?? this.projectSkipDeleteConfirm,
      projectShowNoLabels: projectShowNoLabels ?? this.projectShowNoLabels,
      projectShowImportWarning: projectShowImportWarning ?? this.projectShowImportWarning,
      datasetEnableDuplicate: datasetEnableDuplicate ?? this.datasetEnableDuplicate,
      datasetEnableDelete: datasetEnableDelete ?? this.datasetEnableDelete,
      annotationAllowImageCopy: annotationAllowImageCopy ?? this.annotationAllowImageCopy,
      askConfirmationOnAnnotationRemoval: askConfirmationOnAnnotationRemoval ?? this.askConfirmationOnAnnotationRemoval,
      showExportLabelsButton: showExportLabelsButton ?? this.showExportLabelsButton,
      annotationOpacity: annotationOpacity ?? this.annotationOpacity,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'iconPath': iconPath,
        'datasetImportFolder': datasetImportFolder,
        'datasetExportFolder': datasetExportFolder,
        'thumbnailFolder': thumbnailFolder,
        'themeMode': themeMode,
        'language': language,
        'autoSave': autoSave ? 1 : 0,
        'showTips': showTips ? 1 : 0,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'autoSaveAnnotations': autoSaveAnnotations ? 1 : 0,
        'labelsDeleteAnnotations': labelsDeleteAnnotations ? 1 : 0,
        'labelsSetFirstAsDefault': labelsSetFirstAsDefault ? 1 : 0,
        'projectSkipDeleteConfirm': projectSkipDeleteConfirm ? 1 : 0,
        'projectShowNoLabels': projectShowNoLabels ? 1 : 0,
        'projectShowImportWarning': projectShowImportWarning ? 1 : 0,
        'datasetEnableDuplicate': datasetEnableDuplicate ? 1 : 0,
        'datasetEnableDelete': datasetEnableDelete ? 1 : 0,
        'annotationAllowImageCopy': annotationAllowImageCopy ? 1 : 0,
        'askConfirmationOnAnnotationRemoval': askConfirmationOnAnnotationRemoval ? 1 : 0,
        'showExportLabelsButton': showExportLabelsButton ? 1 : 0,
        'annotationOpacity': annotationOpacity,
      };

  static User fromMap(Map<String, dynamic> map) => User(
        id: map['id'],
        firstName: map['firstName'],
        lastName: map['lastName'],
        email: map['email'],
        iconPath: map['iconPath'],
        datasetImportFolder: map['datasetImportFolder'],
        datasetExportFolder: map['datasetExportFolder'],
        thumbnailFolder: map['thumbnailFolder'],
        themeMode: map['themeMode'],
        language: map['language'],
        autoSave: map['autoSave'] == 1,
        showTips: map['showTips'] == 1,
        createdAt: DateTime.parse(map['createdAt']),
        updatedAt: DateTime.parse(map['updatedAt']),
        autoSaveAnnotations: map['autoSaveAnnotations'] == 1,
        labelsDeleteAnnotations: map['labelsDeleteAnnotations'] == 1,
        labelsSetFirstAsDefault: map['labelsSetFirstAsDefault'] == 1,
        projectSkipDeleteConfirm: map['projectSkipDeleteConfirm'] == 1,
        projectShowNoLabels: map['projectShowNoLabels'] == 1,
        projectShowImportWarning: map['projectShowImportWarning'] == 1,
        datasetEnableDuplicate: map['datasetEnableDuplicate'] == 1,
        datasetEnableDelete: map['datasetEnableDelete'] == 1,
        annotationAllowImageCopy: map['annotationAllowImageCopy'] == 1,
        askConfirmationOnAnnotationRemoval: map['askConfirmationOnAnnotationRemoval'] == null ? true : map['askConfirmationOnAnnotationRemoval'] == 1,
        showExportLabelsButton: map['showExportLabelsButton'] == null ? true : map['showExportLabelsButton'] == 1,
        annotationOpacity: (map['annotationOpacity'] as num?)?.toDouble() ?? 0.35,
      );

  @override
  String toString() {
    return 'User($firstName $lastName, email: $email, theme: $themeMode, autosave: $autoSave)';
  }
}
