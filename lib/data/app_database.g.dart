// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $UsersTable extends Users with TableInfo<$UsersTable, User> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UsersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastNameMeta = const VerificationMeta(
    'lastName',
  );
  @override
  late final GeneratedColumn<String> lastName = GeneratedColumn<String>(
    'last_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _iconPathMeta = const VerificationMeta(
    'iconPath',
  );
  @override
  late final GeneratedColumn<String> iconPath = GeneratedColumn<String>(
    'icon_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _datasetsFolderPathMeta =
      const VerificationMeta('datasetsFolderPath');
  @override
  late final GeneratedColumn<String> datasetsFolderPath =
      GeneratedColumn<String>(
        'datasets_folder_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _thumbnailsFolderPathMeta =
      const VerificationMeta('thumbnailsFolderPath');
  @override
  late final GeneratedColumn<String> thumbnailsFolderPath =
      GeneratedColumn<String>(
        'thumbnails_folder_path',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _themeModeMeta = const VerificationMeta(
    'themeMode',
  );
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
    'theme_mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('light'),
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    lastName,
    email,
    iconPath,
    datasetsFolderPath,
    thumbnailsFolderPath,
    themeMode,
    language,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'users';
  @override
  VerificationContext validateIntegrity(
    Insertable<User> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('last_name')) {
      context.handle(
        _lastNameMeta,
        lastName.isAcceptableOrUnknown(data['last_name']!, _lastNameMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('icon_path')) {
      context.handle(
        _iconPathMeta,
        iconPath.isAcceptableOrUnknown(data['icon_path']!, _iconPathMeta),
      );
    }
    if (data.containsKey('datasets_folder_path')) {
      context.handle(
        _datasetsFolderPathMeta,
        datasetsFolderPath.isAcceptableOrUnknown(
          data['datasets_folder_path']!,
          _datasetsFolderPathMeta,
        ),
      );
    }
    if (data.containsKey('thumbnails_folder_path')) {
      context.handle(
        _thumbnailsFolderPathMeta,
        thumbnailsFolderPath.isAcceptableOrUnknown(
          data['thumbnails_folder_path']!,
          _thumbnailsFolderPathMeta,
        ),
      );
    }
    if (data.containsKey('theme_mode')) {
      context.handle(
        _themeModeMeta,
        themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  User map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return User(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      lastName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_name'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      iconPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_path'],
      ),
      datasetsFolderPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}datasets_folder_path'],
      ),
      thumbnailsFolderPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}thumbnails_folder_path'],
      ),
      themeMode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}theme_mode'],
          )!,
      language:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}language'],
          )!,
    );
  }

  @override
  $UsersTable createAlias(String alias) {
    return $UsersTable(attachedDatabase, alias);
  }
}

class User extends DataClass implements Insertable<User> {
  final int id;
  final String name;
  final String? lastName;
  final String? email;
  final String? iconPath;
  final String? datasetsFolderPath;
  final String? thumbnailsFolderPath;
  final String themeMode;
  final String language;
  const User({
    required this.id,
    required this.name,
    this.lastName,
    this.email,
    this.iconPath,
    this.datasetsFolderPath,
    this.thumbnailsFolderPath,
    required this.themeMode,
    required this.language,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || lastName != null) {
      map['last_name'] = Variable<String>(lastName);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || iconPath != null) {
      map['icon_path'] = Variable<String>(iconPath);
    }
    if (!nullToAbsent || datasetsFolderPath != null) {
      map['datasets_folder_path'] = Variable<String>(datasetsFolderPath);
    }
    if (!nullToAbsent || thumbnailsFolderPath != null) {
      map['thumbnails_folder_path'] = Variable<String>(thumbnailsFolderPath);
    }
    map['theme_mode'] = Variable<String>(themeMode);
    map['language'] = Variable<String>(language);
    return map;
  }

  UsersCompanion toCompanion(bool nullToAbsent) {
    return UsersCompanion(
      id: Value(id),
      name: Value(name),
      lastName:
          lastName == null && nullToAbsent
              ? const Value.absent()
              : Value(lastName),
      email:
          email == null && nullToAbsent ? const Value.absent() : Value(email),
      iconPath:
          iconPath == null && nullToAbsent
              ? const Value.absent()
              : Value(iconPath),
      datasetsFolderPath:
          datasetsFolderPath == null && nullToAbsent
              ? const Value.absent()
              : Value(datasetsFolderPath),
      thumbnailsFolderPath:
          thumbnailsFolderPath == null && nullToAbsent
              ? const Value.absent()
              : Value(thumbnailsFolderPath),
      themeMode: Value(themeMode),
      language: Value(language),
    );
  }

  factory User.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return User(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      lastName: serializer.fromJson<String?>(json['lastName']),
      email: serializer.fromJson<String?>(json['email']),
      iconPath: serializer.fromJson<String?>(json['iconPath']),
      datasetsFolderPath: serializer.fromJson<String?>(
        json['datasetsFolderPath'],
      ),
      thumbnailsFolderPath: serializer.fromJson<String?>(
        json['thumbnailsFolderPath'],
      ),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      language: serializer.fromJson<String>(json['language']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'lastName': serializer.toJson<String?>(lastName),
      'email': serializer.toJson<String?>(email),
      'iconPath': serializer.toJson<String?>(iconPath),
      'datasetsFolderPath': serializer.toJson<String?>(datasetsFolderPath),
      'thumbnailsFolderPath': serializer.toJson<String?>(thumbnailsFolderPath),
      'themeMode': serializer.toJson<String>(themeMode),
      'language': serializer.toJson<String>(language),
    };
  }

  User copyWith({
    int? id,
    String? name,
    Value<String?> lastName = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> iconPath = const Value.absent(),
    Value<String?> datasetsFolderPath = const Value.absent(),
    Value<String?> thumbnailsFolderPath = const Value.absent(),
    String? themeMode,
    String? language,
  }) => User(
    id: id ?? this.id,
    name: name ?? this.name,
    lastName: lastName.present ? lastName.value : this.lastName,
    email: email.present ? email.value : this.email,
    iconPath: iconPath.present ? iconPath.value : this.iconPath,
    datasetsFolderPath:
        datasetsFolderPath.present
            ? datasetsFolderPath.value
            : this.datasetsFolderPath,
    thumbnailsFolderPath:
        thumbnailsFolderPath.present
            ? thumbnailsFolderPath.value
            : this.thumbnailsFolderPath,
    themeMode: themeMode ?? this.themeMode,
    language: language ?? this.language,
  );
  User copyWithCompanion(UsersCompanion data) {
    return User(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      lastName: data.lastName.present ? data.lastName.value : this.lastName,
      email: data.email.present ? data.email.value : this.email,
      iconPath: data.iconPath.present ? data.iconPath.value : this.iconPath,
      datasetsFolderPath:
          data.datasetsFolderPath.present
              ? data.datasetsFolderPath.value
              : this.datasetsFolderPath,
      thumbnailsFolderPath:
          data.thumbnailsFolderPath.present
              ? data.thumbnailsFolderPath.value
              : this.thumbnailsFolderPath,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      language: data.language.present ? data.language.value : this.language,
    );
  }

  @override
  String toString() {
    return (StringBuffer('User(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastName: $lastName, ')
          ..write('email: $email, ')
          ..write('iconPath: $iconPath, ')
          ..write('datasetsFolderPath: $datasetsFolderPath, ')
          ..write('thumbnailsFolderPath: $thumbnailsFolderPath, ')
          ..write('themeMode: $themeMode, ')
          ..write('language: $language')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    lastName,
    email,
    iconPath,
    datasetsFolderPath,
    thumbnailsFolderPath,
    themeMode,
    language,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is User &&
          other.id == this.id &&
          other.name == this.name &&
          other.lastName == this.lastName &&
          other.email == this.email &&
          other.iconPath == this.iconPath &&
          other.datasetsFolderPath == this.datasetsFolderPath &&
          other.thumbnailsFolderPath == this.thumbnailsFolderPath &&
          other.themeMode == this.themeMode &&
          other.language == this.language);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> lastName;
  final Value<String?> email;
  final Value<String?> iconPath;
  final Value<String?> datasetsFolderPath;
  final Value<String?> thumbnailsFolderPath;
  final Value<String> themeMode;
  final Value<String> language;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lastName = const Value.absent(),
    this.email = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.datasetsFolderPath = const Value.absent(),
    this.thumbnailsFolderPath = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.language = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.lastName = const Value.absent(),
    this.email = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.datasetsFolderPath = const Value.absent(),
    this.thumbnailsFolderPath = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.language = const Value.absent(),
  }) : name = Value(name);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? lastName,
    Expression<String>? email,
    Expression<String>? iconPath,
    Expression<String>? datasetsFolderPath,
    Expression<String>? thumbnailsFolderPath,
    Expression<String>? themeMode,
    Expression<String>? language,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (lastName != null) 'last_name': lastName,
      if (email != null) 'email': email,
      if (iconPath != null) 'icon_path': iconPath,
      if (datasetsFolderPath != null)
        'datasets_folder_path': datasetsFolderPath,
      if (thumbnailsFolderPath != null)
        'thumbnails_folder_path': thumbnailsFolderPath,
      if (themeMode != null) 'theme_mode': themeMode,
      if (language != null) 'language': language,
    });
  }

  UsersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? lastName,
    Value<String?>? email,
    Value<String?>? iconPath,
    Value<String?>? datasetsFolderPath,
    Value<String?>? thumbnailsFolderPath,
    Value<String>? themeMode,
    Value<String>? language,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      iconPath: iconPath ?? this.iconPath,
      datasetsFolderPath: datasetsFolderPath ?? this.datasetsFolderPath,
      thumbnailsFolderPath: thumbnailsFolderPath ?? this.thumbnailsFolderPath,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (lastName.present) {
      map['last_name'] = Variable<String>(lastName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (iconPath.present) {
      map['icon_path'] = Variable<String>(iconPath.value);
    }
    if (datasetsFolderPath.present) {
      map['datasets_folder_path'] = Variable<String>(datasetsFolderPath.value);
    }
    if (thumbnailsFolderPath.present) {
      map['thumbnails_folder_path'] = Variable<String>(
        thumbnailsFolderPath.value,
      );
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UsersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('lastName: $lastName, ')
          ..write('email: $email, ')
          ..write('iconPath: $iconPath, ')
          ..write('datasetsFolderPath: $datasetsFolderPath, ')
          ..write('thumbnailsFolderPath: $thumbnailsFolderPath, ')
          ..write('themeMode: $themeMode, ')
          ..write('language: $language')
          ..write(')'))
        .toString();
  }
}

class $ProjectsTable extends Projects with TableInfo<$ProjectsTable, Project> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _iconMeta = const VerificationMeta('icon');
  @override
  late final GeneratedColumn<String> icon = GeneratedColumn<String>(
    'icon',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creationDateMeta = const VerificationMeta(
    'creationDate',
  );
  @override
  late final GeneratedColumn<DateTime> creationDate = GeneratedColumn<DateTime>(
    'creation_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUpdatedMeta = const VerificationMeta(
    'lastUpdated',
  );
  @override
  late final GeneratedColumn<DateTime> lastUpdated = GeneratedColumn<DateTime>(
    'last_updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelsMeta = const VerificationMeta('labels');
  @override
  late final GeneratedColumn<String> labels = GeneratedColumn<String>(
    'labels',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelColorsMeta = const VerificationMeta(
    'labelColors',
  );
  @override
  late final GeneratedColumn<String> labelColors = GeneratedColumn<String>(
    'label_colors',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultDatasetIdMeta = const VerificationMeta(
    'defaultDatasetId',
  );
  @override
  late final GeneratedColumn<String> defaultDatasetId = GeneratedColumn<String>(
    'default_dataset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerIdMeta = const VerificationMeta(
    'ownerId',
  );
  @override
  late final GeneratedColumn<int> ownerId = GeneratedColumn<int>(
    'owner_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES users (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    type,
    icon,
    creationDate,
    lastUpdated,
    labels,
    labelColors,
    defaultDatasetId,
    ownerId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'projects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Project> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('icon')) {
      context.handle(
        _iconMeta,
        icon.isAcceptableOrUnknown(data['icon']!, _iconMeta),
      );
    } else if (isInserting) {
      context.missing(_iconMeta);
    }
    if (data.containsKey('creation_date')) {
      context.handle(
        _creationDateMeta,
        creationDate.isAcceptableOrUnknown(
          data['creation_date']!,
          _creationDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_creationDateMeta);
    }
    if (data.containsKey('last_updated')) {
      context.handle(
        _lastUpdatedMeta,
        lastUpdated.isAcceptableOrUnknown(
          data['last_updated']!,
          _lastUpdatedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUpdatedMeta);
    }
    if (data.containsKey('labels')) {
      context.handle(
        _labelsMeta,
        labels.isAcceptableOrUnknown(data['labels']!, _labelsMeta),
      );
    } else if (isInserting) {
      context.missing(_labelsMeta);
    }
    if (data.containsKey('label_colors')) {
      context.handle(
        _labelColorsMeta,
        labelColors.isAcceptableOrUnknown(
          data['label_colors']!,
          _labelColorsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_labelColorsMeta);
    }
    if (data.containsKey('default_dataset_id')) {
      context.handle(
        _defaultDatasetIdMeta,
        defaultDatasetId.isAcceptableOrUnknown(
          data['default_dataset_id']!,
          _defaultDatasetIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_defaultDatasetIdMeta);
    }
    if (data.containsKey('owner_id')) {
      context.handle(
        _ownerIdMeta,
        ownerId.isAcceptableOrUnknown(data['owner_id']!, _ownerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Project map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Project(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}type'],
          )!,
      icon:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}icon'],
          )!,
      creationDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}creation_date'],
          )!,
      lastUpdated:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}last_updated'],
          )!,
      labels:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}labels'],
          )!,
      labelColors:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}label_colors'],
          )!,
      defaultDatasetId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}default_dataset_id'],
          )!,
      ownerId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}owner_id'],
          )!,
    );
  }

  @override
  $ProjectsTable createAlias(String alias) {
    return $ProjectsTable(attachedDatabase, alias);
  }
}

class Project extends DataClass implements Insertable<Project> {
  final int id;
  final String name;
  final String type;
  final String icon;
  final DateTime creationDate;
  final DateTime lastUpdated;
  final String labels;
  final String labelColors;
  final String defaultDatasetId;
  final int ownerId;
  const Project({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.creationDate,
    required this.lastUpdated,
    required this.labels,
    required this.labelColors,
    required this.defaultDatasetId,
    required this.ownerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    map['icon'] = Variable<String>(icon);
    map['creation_date'] = Variable<DateTime>(creationDate);
    map['last_updated'] = Variable<DateTime>(lastUpdated);
    map['labels'] = Variable<String>(labels);
    map['label_colors'] = Variable<String>(labelColors);
    map['default_dataset_id'] = Variable<String>(defaultDatasetId);
    map['owner_id'] = Variable<int>(ownerId);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      icon: Value(icon),
      creationDate: Value(creationDate),
      lastUpdated: Value(lastUpdated),
      labels: Value(labels),
      labelColors: Value(labelColors),
      defaultDatasetId: Value(defaultDatasetId),
      ownerId: Value(ownerId),
    );
  }

  factory Project.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Project(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      icon: serializer.fromJson<String>(json['icon']),
      creationDate: serializer.fromJson<DateTime>(json['creationDate']),
      lastUpdated: serializer.fromJson<DateTime>(json['lastUpdated']),
      labels: serializer.fromJson<String>(json['labels']),
      labelColors: serializer.fromJson<String>(json['labelColors']),
      defaultDatasetId: serializer.fromJson<String>(json['defaultDatasetId']),
      ownerId: serializer.fromJson<int>(json['ownerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'icon': serializer.toJson<String>(icon),
      'creationDate': serializer.toJson<DateTime>(creationDate),
      'lastUpdated': serializer.toJson<DateTime>(lastUpdated),
      'labels': serializer.toJson<String>(labels),
      'labelColors': serializer.toJson<String>(labelColors),
      'defaultDatasetId': serializer.toJson<String>(defaultDatasetId),
      'ownerId': serializer.toJson<int>(ownerId),
    };
  }

  Project copyWith({
    int? id,
    String? name,
    String? type,
    String? icon,
    DateTime? creationDate,
    DateTime? lastUpdated,
    String? labels,
    String? labelColors,
    String? defaultDatasetId,
    int? ownerId,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    icon: icon ?? this.icon,
    creationDate: creationDate ?? this.creationDate,
    lastUpdated: lastUpdated ?? this.lastUpdated,
    labels: labels ?? this.labels,
    labelColors: labelColors ?? this.labelColors,
    defaultDatasetId: defaultDatasetId ?? this.defaultDatasetId,
    ownerId: ownerId ?? this.ownerId,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      icon: data.icon.present ? data.icon.value : this.icon,
      creationDate:
          data.creationDate.present
              ? data.creationDate.value
              : this.creationDate,
      lastUpdated:
          data.lastUpdated.present ? data.lastUpdated.value : this.lastUpdated,
      labels: data.labels.present ? data.labels.value : this.labels,
      labelColors:
          data.labelColors.present ? data.labelColors.value : this.labelColors,
      defaultDatasetId:
          data.defaultDatasetId.present
              ? data.defaultDatasetId.value
              : this.defaultDatasetId,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('creationDate: $creationDate, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('labels: $labels, ')
          ..write('labelColors: $labelColors, ')
          ..write('defaultDatasetId: $defaultDatasetId, ')
          ..write('ownerId: $ownerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    type,
    icon,
    creationDate,
    lastUpdated,
    labels,
    labelColors,
    defaultDatasetId,
    ownerId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.icon == this.icon &&
          other.creationDate == this.creationDate &&
          other.lastUpdated == this.lastUpdated &&
          other.labels == this.labels &&
          other.labelColors == this.labelColors &&
          other.defaultDatasetId == this.defaultDatasetId &&
          other.ownerId == this.ownerId);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String> icon;
  final Value<DateTime> creationDate;
  final Value<DateTime> lastUpdated;
  final Value<String> labels;
  final Value<String> labelColors;
  final Value<String> defaultDatasetId;
  final Value<int> ownerId;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.icon = const Value.absent(),
    this.creationDate = const Value.absent(),
    this.lastUpdated = const Value.absent(),
    this.labels = const Value.absent(),
    this.labelColors = const Value.absent(),
    this.defaultDatasetId = const Value.absent(),
    this.ownerId = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String type,
    required String icon,
    required DateTime creationDate,
    required DateTime lastUpdated,
    required String labels,
    required String labelColors,
    required String defaultDatasetId,
    required int ownerId,
  }) : name = Value(name),
       type = Value(type),
       icon = Value(icon),
       creationDate = Value(creationDate),
       lastUpdated = Value(lastUpdated),
       labels = Value(labels),
       labelColors = Value(labelColors),
       defaultDatasetId = Value(defaultDatasetId),
       ownerId = Value(ownerId);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? icon,
    Expression<DateTime>? creationDate,
    Expression<DateTime>? lastUpdated,
    Expression<String>? labels,
    Expression<String>? labelColors,
    Expression<String>? defaultDatasetId,
    Expression<int>? ownerId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (icon != null) 'icon': icon,
      if (creationDate != null) 'creation_date': creationDate,
      if (lastUpdated != null) 'last_updated': lastUpdated,
      if (labels != null) 'labels': labels,
      if (labelColors != null) 'label_colors': labelColors,
      if (defaultDatasetId != null) 'default_dataset_id': defaultDatasetId,
      if (ownerId != null) 'owner_id': ownerId,
    });
  }

  ProjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? type,
    Value<String>? icon,
    Value<DateTime>? creationDate,
    Value<DateTime>? lastUpdated,
    Value<String>? labels,
    Value<String>? labelColors,
    Value<String>? defaultDatasetId,
    Value<int>? ownerId,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      creationDate: creationDate ?? this.creationDate,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      labels: labels ?? this.labels,
      labelColors: labelColors ?? this.labelColors,
      defaultDatasetId: defaultDatasetId ?? this.defaultDatasetId,
      ownerId: ownerId ?? this.ownerId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (icon.present) {
      map['icon'] = Variable<String>(icon.value);
    }
    if (creationDate.present) {
      map['creation_date'] = Variable<DateTime>(creationDate.value);
    }
    if (lastUpdated.present) {
      map['last_updated'] = Variable<DateTime>(lastUpdated.value);
    }
    if (labels.present) {
      map['labels'] = Variable<String>(labels.value);
    }
    if (labelColors.present) {
      map['label_colors'] = Variable<String>(labelColors.value);
    }
    if (defaultDatasetId.present) {
      map['default_dataset_id'] = Variable<String>(defaultDatasetId.value);
    }
    if (ownerId.present) {
      map['owner_id'] = Variable<int>(ownerId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('icon: $icon, ')
          ..write('creationDate: $creationDate, ')
          ..write('lastUpdated: $lastUpdated, ')
          ..write('labels: $labels, ')
          ..write('labelColors: $labelColors, ')
          ..write('defaultDatasetId: $defaultDatasetId, ')
          ..write('ownerId: $ownerId')
          ..write(')'))
        .toString();
  }
}

class $DatasetsTable extends Datasets with TableInfo<$DatasetsTable, Dataset> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DatasetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _projectIdMeta = const VerificationMeta(
    'projectId',
  );
  @override
  late final GeneratedColumn<int> projectId = GeneratedColumn<int>(
    'project_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES projects (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    projectId,
    name,
    description,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'datasets';
  @override
  VerificationContext validateIntegrity(
    Insertable<Dataset> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Dataset map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Dataset(
      id:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}id'],
          )!,
      projectId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}project_id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
    );
  }

  @override
  $DatasetsTable createAlias(String alias) {
    return $DatasetsTable(attachedDatabase, alias);
  }
}

class Dataset extends DataClass implements Insertable<Dataset> {
  final String id;
  final int projectId;
  final String name;
  final String? description;
  final DateTime createdAt;
  const Dataset({
    required this.id,
    required this.projectId,
    required this.name,
    this.description,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['project_id'] = Variable<int>(projectId);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DatasetsCompanion toCompanion(bool nullToAbsent) {
    return DatasetsCompanion(
      id: Value(id),
      projectId: Value(projectId),
      name: Value(name),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory Dataset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dataset(
      id: serializer.fromJson<String>(json['id']),
      projectId: serializer.fromJson<int>(json['projectId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'projectId': serializer.toJson<int>(projectId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Dataset copyWith({
    String? id,
    int? projectId,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
  }) => Dataset(
    id: id ?? this.id,
    projectId: projectId ?? this.projectId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
  );
  Dataset copyWithCompanion(DatasetsCompanion data) {
    return Dataset(
      id: data.id.present ? data.id.value : this.id,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      name: data.name.present ? data.name.value : this.name,
      description:
          data.description.present ? data.description.value : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dataset(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, projectId, name, description, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dataset &&
          other.id == this.id &&
          other.projectId == this.projectId &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class DatasetsCompanion extends UpdateCompanion<Dataset> {
  final Value<String> id;
  final Value<int> projectId;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DatasetsCompanion({
    this.id = const Value.absent(),
    this.projectId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DatasetsCompanion.insert({
    required String id,
    required int projectId,
    required String name,
    this.description = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       projectId = Value(projectId),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<Dataset> custom({
    Expression<String>? id,
    Expression<int>? projectId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (projectId != null) 'project_id': projectId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DatasetsCompanion copyWith({
    Value<String>? id,
    Value<int>? projectId,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DatasetsCompanion(
      id: id ?? this.id,
      projectId: projectId ?? this.projectId,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatasetsCompanion(')
          ..write('id: $id, ')
          ..write('projectId: $projectId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MediaItemsTable extends MediaItems
    with TableInfo<$MediaItemsTable, MediaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'UNIQUE',
  );
  static const VerificationMeta _datasetIdMeta = const VerificationMeta(
    'datasetId',
  );
  @override
  late final GeneratedColumn<String> datasetId = GeneratedColumn<String>(
    'dataset_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MediaType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<MediaType>($MediaItemsTable.$convertertype);
  static const VerificationMeta _uploadDateMeta = const VerificationMeta(
    'uploadDate',
  );
  @override
  late final GeneratedColumn<DateTime> uploadDate = GeneratedColumn<DateTime>(
    'upload_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ownerMeta = const VerificationMeta('owner');
  @override
  late final GeneratedColumn<String> owner = GeneratedColumn<String>(
    'owner',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastAnnotatorMeta = const VerificationMeta(
    'lastAnnotator',
  );
  @override
  late final GeneratedColumn<String> lastAnnotator = GeneratedColumn<String>(
    'last_annotator',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastAnnotatedDateMeta = const VerificationMeta(
    'lastAnnotatedDate',
  );
  @override
  late final GeneratedColumn<DateTime> lastAnnotatedDate =
      GeneratedColumn<DateTime>(
        'last_annotated_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _numberOfFramesMeta = const VerificationMeta(
    'numberOfFrames',
  );
  @override
  late final GeneratedColumn<int> numberOfFrames = GeneratedColumn<int>(
    'number_of_frames',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    datasetId,
    filePath,
    type,
    uploadDate,
    owner,
    lastAnnotator,
    lastAnnotatedDate,
    numberOfFrames,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('dataset_id')) {
      context.handle(
        _datasetIdMeta,
        datasetId.isAcceptableOrUnknown(data['dataset_id']!, _datasetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_datasetIdMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('upload_date')) {
      context.handle(
        _uploadDateMeta,
        uploadDate.isAcceptableOrUnknown(data['upload_date']!, _uploadDateMeta),
      );
    } else if (isInserting) {
      context.missing(_uploadDateMeta);
    }
    if (data.containsKey('owner')) {
      context.handle(
        _ownerMeta,
        owner.isAcceptableOrUnknown(data['owner']!, _ownerMeta),
      );
    } else if (isInserting) {
      context.missing(_ownerMeta);
    }
    if (data.containsKey('last_annotator')) {
      context.handle(
        _lastAnnotatorMeta,
        lastAnnotator.isAcceptableOrUnknown(
          data['last_annotator']!,
          _lastAnnotatorMeta,
        ),
      );
    }
    if (data.containsKey('last_annotated_date')) {
      context.handle(
        _lastAnnotatedDateMeta,
        lastAnnotatedDate.isAcceptableOrUnknown(
          data['last_annotated_date']!,
          _lastAnnotatedDateMeta,
        ),
      );
    }
    if (data.containsKey('number_of_frames')) {
      context.handle(
        _numberOfFramesMeta,
        numberOfFrames.isAcceptableOrUnknown(
          data['number_of_frames']!,
          _numberOfFramesMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MediaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      ),
      datasetId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}dataset_id'],
          )!,
      filePath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_path'],
          )!,
      type: $MediaItemsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      uploadDate:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}upload_date'],
          )!,
      owner:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}owner'],
          )!,
      lastAnnotator: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_annotator'],
      ),
      lastAnnotatedDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_annotated_date'],
      ),
      numberOfFrames: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}number_of_frames'],
      ),
    );
  }

  @override
  $MediaItemsTable createAlias(String alias) {
    return $MediaItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MediaType, int, int> $convertertype =
      const EnumIndexConverter<MediaType>(MediaType.values);
}

class MediaItem extends DataClass implements Insertable<MediaItem> {
  final String? id;
  final String datasetId;
  final String filePath;
  final MediaType type;
  final DateTime uploadDate;
  final String owner;
  final String? lastAnnotator;
  final DateTime? lastAnnotatedDate;
  final int? numberOfFrames;
  const MediaItem({
    this.id,
    required this.datasetId,
    required this.filePath,
    required this.type,
    required this.uploadDate,
    required this.owner,
    this.lastAnnotator,
    this.lastAnnotatedDate,
    this.numberOfFrames,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (!nullToAbsent || id != null) {
      map['id'] = Variable<String>(id);
    }
    map['dataset_id'] = Variable<String>(datasetId);
    map['file_path'] = Variable<String>(filePath);
    {
      map['type'] = Variable<int>($MediaItemsTable.$convertertype.toSql(type));
    }
    map['upload_date'] = Variable<DateTime>(uploadDate);
    map['owner'] = Variable<String>(owner);
    if (!nullToAbsent || lastAnnotator != null) {
      map['last_annotator'] = Variable<String>(lastAnnotator);
    }
    if (!nullToAbsent || lastAnnotatedDate != null) {
      map['last_annotated_date'] = Variable<DateTime>(lastAnnotatedDate);
    }
    if (!nullToAbsent || numberOfFrames != null) {
      map['number_of_frames'] = Variable<int>(numberOfFrames);
    }
    return map;
  }

  MediaItemsCompanion toCompanion(bool nullToAbsent) {
    return MediaItemsCompanion(
      id: id == null && nullToAbsent ? const Value.absent() : Value(id),
      datasetId: Value(datasetId),
      filePath: Value(filePath),
      type: Value(type),
      uploadDate: Value(uploadDate),
      owner: Value(owner),
      lastAnnotator:
          lastAnnotator == null && nullToAbsent
              ? const Value.absent()
              : Value(lastAnnotator),
      lastAnnotatedDate:
          lastAnnotatedDate == null && nullToAbsent
              ? const Value.absent()
              : Value(lastAnnotatedDate),
      numberOfFrames:
          numberOfFrames == null && nullToAbsent
              ? const Value.absent()
              : Value(numberOfFrames),
    );
  }

  factory MediaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItem(
      id: serializer.fromJson<String?>(json['id']),
      datasetId: serializer.fromJson<String>(json['datasetId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      type: $MediaItemsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      uploadDate: serializer.fromJson<DateTime>(json['uploadDate']),
      owner: serializer.fromJson<String>(json['owner']),
      lastAnnotator: serializer.fromJson<String?>(json['lastAnnotator']),
      lastAnnotatedDate: serializer.fromJson<DateTime?>(
        json['lastAnnotatedDate'],
      ),
      numberOfFrames: serializer.fromJson<int?>(json['numberOfFrames']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String?>(id),
      'datasetId': serializer.toJson<String>(datasetId),
      'filePath': serializer.toJson<String>(filePath),
      'type': serializer.toJson<int>(
        $MediaItemsTable.$convertertype.toJson(type),
      ),
      'uploadDate': serializer.toJson<DateTime>(uploadDate),
      'owner': serializer.toJson<String>(owner),
      'lastAnnotator': serializer.toJson<String?>(lastAnnotator),
      'lastAnnotatedDate': serializer.toJson<DateTime?>(lastAnnotatedDate),
      'numberOfFrames': serializer.toJson<int?>(numberOfFrames),
    };
  }

  MediaItem copyWith({
    Value<String?> id = const Value.absent(),
    String? datasetId,
    String? filePath,
    MediaType? type,
    DateTime? uploadDate,
    String? owner,
    Value<String?> lastAnnotator = const Value.absent(),
    Value<DateTime?> lastAnnotatedDate = const Value.absent(),
    Value<int?> numberOfFrames = const Value.absent(),
  }) => MediaItem(
    id: id.present ? id.value : this.id,
    datasetId: datasetId ?? this.datasetId,
    filePath: filePath ?? this.filePath,
    type: type ?? this.type,
    uploadDate: uploadDate ?? this.uploadDate,
    owner: owner ?? this.owner,
    lastAnnotator:
        lastAnnotator.present ? lastAnnotator.value : this.lastAnnotator,
    lastAnnotatedDate:
        lastAnnotatedDate.present
            ? lastAnnotatedDate.value
            : this.lastAnnotatedDate,
    numberOfFrames:
        numberOfFrames.present ? numberOfFrames.value : this.numberOfFrames,
  );
  MediaItem copyWithCompanion(MediaItemsCompanion data) {
    return MediaItem(
      id: data.id.present ? data.id.value : this.id,
      datasetId: data.datasetId.present ? data.datasetId.value : this.datasetId,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      type: data.type.present ? data.type.value : this.type,
      uploadDate:
          data.uploadDate.present ? data.uploadDate.value : this.uploadDate,
      owner: data.owner.present ? data.owner.value : this.owner,
      lastAnnotator:
          data.lastAnnotator.present
              ? data.lastAnnotator.value
              : this.lastAnnotator,
      lastAnnotatedDate:
          data.lastAnnotatedDate.present
              ? data.lastAnnotatedDate.value
              : this.lastAnnotatedDate,
      numberOfFrames:
          data.numberOfFrames.present
              ? data.numberOfFrames.value
              : this.numberOfFrames,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItem(')
          ..write('id: $id, ')
          ..write('datasetId: $datasetId, ')
          ..write('filePath: $filePath, ')
          ..write('type: $type, ')
          ..write('uploadDate: $uploadDate, ')
          ..write('owner: $owner, ')
          ..write('lastAnnotator: $lastAnnotator, ')
          ..write('lastAnnotatedDate: $lastAnnotatedDate, ')
          ..write('numberOfFrames: $numberOfFrames')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    datasetId,
    filePath,
    type,
    uploadDate,
    owner,
    lastAnnotator,
    lastAnnotatedDate,
    numberOfFrames,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItem &&
          other.id == this.id &&
          other.datasetId == this.datasetId &&
          other.filePath == this.filePath &&
          other.type == this.type &&
          other.uploadDate == this.uploadDate &&
          other.owner == this.owner &&
          other.lastAnnotator == this.lastAnnotator &&
          other.lastAnnotatedDate == this.lastAnnotatedDate &&
          other.numberOfFrames == this.numberOfFrames);
}

class MediaItemsCompanion extends UpdateCompanion<MediaItem> {
  final Value<String?> id;
  final Value<String> datasetId;
  final Value<String> filePath;
  final Value<MediaType> type;
  final Value<DateTime> uploadDate;
  final Value<String> owner;
  final Value<String?> lastAnnotator;
  final Value<DateTime?> lastAnnotatedDate;
  final Value<int?> numberOfFrames;
  final Value<int> rowid;
  const MediaItemsCompanion({
    this.id = const Value.absent(),
    this.datasetId = const Value.absent(),
    this.filePath = const Value.absent(),
    this.type = const Value.absent(),
    this.uploadDate = const Value.absent(),
    this.owner = const Value.absent(),
    this.lastAnnotator = const Value.absent(),
    this.lastAnnotatedDate = const Value.absent(),
    this.numberOfFrames = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MediaItemsCompanion.insert({
    this.id = const Value.absent(),
    required String datasetId,
    required String filePath,
    required MediaType type,
    required DateTime uploadDate,
    required String owner,
    this.lastAnnotator = const Value.absent(),
    this.lastAnnotatedDate = const Value.absent(),
    this.numberOfFrames = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : datasetId = Value(datasetId),
       filePath = Value(filePath),
       type = Value(type),
       uploadDate = Value(uploadDate),
       owner = Value(owner);
  static Insertable<MediaItem> custom({
    Expression<String>? id,
    Expression<String>? datasetId,
    Expression<String>? filePath,
    Expression<int>? type,
    Expression<DateTime>? uploadDate,
    Expression<String>? owner,
    Expression<String>? lastAnnotator,
    Expression<DateTime>? lastAnnotatedDate,
    Expression<int>? numberOfFrames,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (datasetId != null) 'dataset_id': datasetId,
      if (filePath != null) 'file_path': filePath,
      if (type != null) 'type': type,
      if (uploadDate != null) 'upload_date': uploadDate,
      if (owner != null) 'owner': owner,
      if (lastAnnotator != null) 'last_annotator': lastAnnotator,
      if (lastAnnotatedDate != null) 'last_annotated_date': lastAnnotatedDate,
      if (numberOfFrames != null) 'number_of_frames': numberOfFrames,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MediaItemsCompanion copyWith({
    Value<String?>? id,
    Value<String>? datasetId,
    Value<String>? filePath,
    Value<MediaType>? type,
    Value<DateTime>? uploadDate,
    Value<String>? owner,
    Value<String?>? lastAnnotator,
    Value<DateTime?>? lastAnnotatedDate,
    Value<int?>? numberOfFrames,
    Value<int>? rowid,
  }) {
    return MediaItemsCompanion(
      id: id ?? this.id,
      datasetId: datasetId ?? this.datasetId,
      filePath: filePath ?? this.filePath,
      type: type ?? this.type,
      uploadDate: uploadDate ?? this.uploadDate,
      owner: owner ?? this.owner,
      lastAnnotator: lastAnnotator ?? this.lastAnnotator,
      lastAnnotatedDate: lastAnnotatedDate ?? this.lastAnnotatedDate,
      numberOfFrames: numberOfFrames ?? this.numberOfFrames,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (datasetId.present) {
      map['dataset_id'] = Variable<String>(datasetId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $MediaItemsTable.$convertertype.toSql(type.value),
      );
    }
    if (uploadDate.present) {
      map['upload_date'] = Variable<DateTime>(uploadDate.value);
    }
    if (owner.present) {
      map['owner'] = Variable<String>(owner.value);
    }
    if (lastAnnotator.present) {
      map['last_annotator'] = Variable<String>(lastAnnotator.value);
    }
    if (lastAnnotatedDate.present) {
      map['last_annotated_date'] = Variable<DateTime>(lastAnnotatedDate.value);
    }
    if (numberOfFrames.present) {
      map['number_of_frames'] = Variable<int>(numberOfFrames.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsCompanion(')
          ..write('id: $id, ')
          ..write('datasetId: $datasetId, ')
          ..write('filePath: $filePath, ')
          ..write('type: $type, ')
          ..write('uploadDate: $uploadDate, ')
          ..write('owner: $owner, ')
          ..write('lastAnnotator: $lastAnnotator, ')
          ..write('lastAnnotatedDate: $lastAnnotatedDate, ')
          ..write('numberOfFrames: $numberOfFrames, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $UsersTable users = $UsersTable(this);
  late final $ProjectsTable projects = $ProjectsTable(this);
  late final $DatasetsTable datasets = $DatasetsTable(this);
  late final $MediaItemsTable mediaItems = $MediaItemsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    users,
    projects,
    datasets,
    mediaItems,
  ];
}

typedef $$UsersTableCreateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> lastName,
      Value<String?> email,
      Value<String?> iconPath,
      Value<String?> datasetsFolderPath,
      Value<String?> thumbnailsFolderPath,
      Value<String> themeMode,
      Value<String> language,
    });
typedef $$UsersTableUpdateCompanionBuilder =
    UsersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> lastName,
      Value<String?> email,
      Value<String?> iconPath,
      Value<String?> datasetsFolderPath,
      Value<String?> thumbnailsFolderPath,
      Value<String> themeMode,
      Value<String> language,
    });

final class $$UsersTableReferences
    extends BaseReferences<_$AppDatabase, $UsersTable, User> {
  $$UsersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ProjectsTable, List<Project>> _projectsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.projects,
    aliasName: $_aliasNameGenerator(db.users.id, db.projects.ownerId),
  );

  $$ProjectsTableProcessedTableManager get projectsRefs {
    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.ownerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_projectsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UsersTableFilterComposer extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datasetsFolderPath => $composableBuilder(
    column: $table.datasetsFolderPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get thumbnailsFolderPath => $composableBuilder(
    column: $table.thumbnailsFolderPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> projectsRefs(
    Expression<bool> Function($$ProjectsTableFilterComposer f) f,
  ) {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableOrderingComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastName => $composableBuilder(
    column: $table.lastName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datasetsFolderPath => $composableBuilder(
    column: $table.datasetsFolderPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get thumbnailsFolderPath => $composableBuilder(
    column: $table.thumbnailsFolderPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get themeMode => $composableBuilder(
    column: $table.themeMode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UsersTableAnnotationComposer
    extends Composer<_$AppDatabase, $UsersTable> {
  $$UsersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get lastName =>
      $composableBuilder(column: $table.lastName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get iconPath =>
      $composableBuilder(column: $table.iconPath, builder: (column) => column);

  GeneratedColumn<String> get datasetsFolderPath => $composableBuilder(
    column: $table.datasetsFolderPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get thumbnailsFolderPath => $composableBuilder(
    column: $table.thumbnailsFolderPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  Expression<T> projectsRefs<T extends Object>(
    Expression<T> Function($$ProjectsTableAnnotationComposer a) f,
  ) {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.ownerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UsersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UsersTable,
          User,
          $$UsersTableFilterComposer,
          $$UsersTableOrderingComposer,
          $$UsersTableAnnotationComposer,
          $$UsersTableCreateCompanionBuilder,
          $$UsersTableUpdateCompanionBuilder,
          (User, $$UsersTableReferences),
          User,
          PrefetchHooks Function({bool projectsRefs})
        > {
  $$UsersTableTableManager(_$AppDatabase db, $UsersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$UsersTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$UsersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$UsersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> lastName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> iconPath = const Value.absent(),
                Value<String?> datasetsFolderPath = const Value.absent(),
                Value<String?> thumbnailsFolderPath = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> language = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                name: name,
                lastName: lastName,
                email: email,
                iconPath: iconPath,
                datasetsFolderPath: datasetsFolderPath,
                thumbnailsFolderPath: thumbnailsFolderPath,
                themeMode: themeMode,
                language: language,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> lastName = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> iconPath = const Value.absent(),
                Value<String?> datasetsFolderPath = const Value.absent(),
                Value<String?> thumbnailsFolderPath = const Value.absent(),
                Value<String> themeMode = const Value.absent(),
                Value<String> language = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                name: name,
                lastName: lastName,
                email: email,
                iconPath: iconPath,
                datasetsFolderPath: datasetsFolderPath,
                thumbnailsFolderPath: thumbnailsFolderPath,
                themeMode: themeMode,
                language: language,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$UsersTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({projectsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (projectsRefs) db.projects],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (projectsRefs)
                    await $_getPrefetchedData<User, $UsersTable, Project>(
                      currentTable: table,
                      referencedTable: $$UsersTableReferences
                          ._projectsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$UsersTableReferences(
                                db,
                                table,
                                p0,
                              ).projectsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.ownerId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UsersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UsersTable,
      User,
      $$UsersTableFilterComposer,
      $$UsersTableOrderingComposer,
      $$UsersTableAnnotationComposer,
      $$UsersTableCreateCompanionBuilder,
      $$UsersTableUpdateCompanionBuilder,
      (User, $$UsersTableReferences),
      User,
      PrefetchHooks Function({bool projectsRefs})
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      required String name,
      required String type,
      required String icon,
      required DateTime creationDate,
      required DateTime lastUpdated,
      required String labels,
      required String labelColors,
      required String defaultDatasetId,
      required int ownerId,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> type,
      Value<String> icon,
      Value<DateTime> creationDate,
      Value<DateTime> lastUpdated,
      Value<String> labels,
      Value<String> labelColors,
      Value<String> defaultDatasetId,
      Value<int> ownerId,
    });

final class $$ProjectsTableReferences
    extends BaseReferences<_$AppDatabase, $ProjectsTable, Project> {
  $$ProjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UsersTable _ownerIdTable(_$AppDatabase db) => db.users.createAlias(
    $_aliasNameGenerator(db.projects.ownerId, db.users.id),
  );

  $$UsersTableProcessedTableManager get ownerId {
    final $_column = $_itemColumn<int>('owner_id')!;

    final manager = $$UsersTableTableManager(
      $_db,
      $_db.users,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_ownerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DatasetsTable, List<Dataset>> _datasetsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.datasets,
    aliasName: $_aliasNameGenerator(db.projects.id, db.datasets.projectId),
  );

  $$DatasetsTableProcessedTableManager get datasetsRefs {
    final manager = $$DatasetsTableTableManager(
      $_db,
      $_db.datasets,
    ).filter((f) => f.projectId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_datasetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ProjectsTableFilterComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get labelColors => $composableBuilder(
    column: $table.labelColors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get defaultDatasetId => $composableBuilder(
    column: $table.defaultDatasetId,
    builder: (column) => ColumnFilters(column),
  );

  $$UsersTableFilterComposer get ownerId {
    final $$UsersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableFilterComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> datasetsRefs(
    Expression<bool> Function($$DatasetsTableFilterComposer f) f,
  ) {
    final $$DatasetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.datasets,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DatasetsTableFilterComposer(
            $db: $db,
            $table: $db.datasets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get icon => $composableBuilder(
    column: $table.icon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labels => $composableBuilder(
    column: $table.labels,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get labelColors => $composableBuilder(
    column: $table.labelColors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get defaultDatasetId => $composableBuilder(
    column: $table.defaultDatasetId,
    builder: (column) => ColumnOrderings(column),
  );

  $$UsersTableOrderingComposer get ownerId {
    final $$UsersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableOrderingComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ProjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProjectsTable> {
  $$ProjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get icon =>
      $composableBuilder(column: $table.icon, builder: (column) => column);

  GeneratedColumn<DateTime> get creationDate => $composableBuilder(
    column: $table.creationDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastUpdated => $composableBuilder(
    column: $table.lastUpdated,
    builder: (column) => column,
  );

  GeneratedColumn<String> get labels =>
      $composableBuilder(column: $table.labels, builder: (column) => column);

  GeneratedColumn<String> get labelColors => $composableBuilder(
    column: $table.labelColors,
    builder: (column) => column,
  );

  GeneratedColumn<String> get defaultDatasetId => $composableBuilder(
    column: $table.defaultDatasetId,
    builder: (column) => column,
  );

  $$UsersTableAnnotationComposer get ownerId {
    final $$UsersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.ownerId,
      referencedTable: $db.users,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UsersTableAnnotationComposer(
            $db: $db,
            $table: $db.users,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> datasetsRefs<T extends Object>(
    Expression<T> Function($$DatasetsTableAnnotationComposer a) f,
  ) {
    final $$DatasetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.datasets,
      getReferencedColumn: (t) => t.projectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DatasetsTableAnnotationComposer(
            $db: $db,
            $table: $db.datasets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ProjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProjectsTable,
          Project,
          $$ProjectsTableFilterComposer,
          $$ProjectsTableOrderingComposer,
          $$ProjectsTableAnnotationComposer,
          $$ProjectsTableCreateCompanionBuilder,
          $$ProjectsTableUpdateCompanionBuilder,
          (Project, $$ProjectsTableReferences),
          Project,
          PrefetchHooks Function({bool ownerId, bool datasetsRefs})
        > {
  $$ProjectsTableTableManager(_$AppDatabase db, $ProjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$ProjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$ProjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$ProjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> icon = const Value.absent(),
                Value<DateTime> creationDate = const Value.absent(),
                Value<DateTime> lastUpdated = const Value.absent(),
                Value<String> labels = const Value.absent(),
                Value<String> labelColors = const Value.absent(),
                Value<String> defaultDatasetId = const Value.absent(),
                Value<int> ownerId = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                type: type,
                icon: icon,
                creationDate: creationDate,
                lastUpdated: lastUpdated,
                labels: labels,
                labelColors: labelColors,
                defaultDatasetId: defaultDatasetId,
                ownerId: ownerId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String type,
                required String icon,
                required DateTime creationDate,
                required DateTime lastUpdated,
                required String labels,
                required String labelColors,
                required String defaultDatasetId,
                required int ownerId,
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                type: type,
                icon: icon,
                creationDate: creationDate,
                lastUpdated: lastUpdated,
                labels: labels,
                labelColors: labelColors,
                defaultDatasetId: defaultDatasetId,
                ownerId: ownerId,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$ProjectsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({ownerId = false, datasetsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (datasetsRefs) db.datasets],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (ownerId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.ownerId,
                            referencedTable: $$ProjectsTableReferences
                                ._ownerIdTable(db),
                            referencedColumn:
                                $$ProjectsTableReferences._ownerIdTable(db).id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (datasetsRefs)
                    await $_getPrefetchedData<Project, $ProjectsTable, Dataset>(
                      currentTable: table,
                      referencedTable: $$ProjectsTableReferences
                          ._datasetsRefsTable(db),
                      managerFromTypedResult:
                          (p0) =>
                              $$ProjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).datasetsRefs,
                      referencedItemsForCurrentItem:
                          (item, referencedItems) => referencedItems.where(
                            (e) => e.projectId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ProjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProjectsTable,
      Project,
      $$ProjectsTableFilterComposer,
      $$ProjectsTableOrderingComposer,
      $$ProjectsTableAnnotationComposer,
      $$ProjectsTableCreateCompanionBuilder,
      $$ProjectsTableUpdateCompanionBuilder,
      (Project, $$ProjectsTableReferences),
      Project,
      PrefetchHooks Function({bool ownerId, bool datasetsRefs})
    >;
typedef $$DatasetsTableCreateCompanionBuilder =
    DatasetsCompanion Function({
      required String id,
      required int projectId,
      required String name,
      Value<String?> description,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DatasetsTableUpdateCompanionBuilder =
    DatasetsCompanion Function({
      Value<String> id,
      Value<int> projectId,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$DatasetsTableReferences
    extends BaseReferences<_$AppDatabase, $DatasetsTable, Dataset> {
  $$DatasetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ProjectsTable _projectIdTable(_$AppDatabase db) => db.projects
      .createAlias($_aliasNameGenerator(db.datasets.projectId, db.projects.id));

  $$ProjectsTableProcessedTableManager get projectId {
    final $_column = $_itemColumn<int>('project_id')!;

    final manager = $$ProjectsTableTableManager(
      $_db,
      $_db.projects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_projectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DatasetsTableFilterComposer
    extends Composer<_$AppDatabase, $DatasetsTable> {
  $$DatasetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ProjectsTableFilterComposer get projectId {
    final $$ProjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableFilterComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DatasetsTableOrderingComposer
    extends Composer<_$AppDatabase, $DatasetsTable> {
  $$DatasetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ProjectsTableOrderingComposer get projectId {
    final $$ProjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableOrderingComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DatasetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DatasetsTable> {
  $$DatasetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ProjectsTableAnnotationComposer get projectId {
    final $$ProjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.projectId,
      referencedTable: $db.projects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ProjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.projects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DatasetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DatasetsTable,
          Dataset,
          $$DatasetsTableFilterComposer,
          $$DatasetsTableOrderingComposer,
          $$DatasetsTableAnnotationComposer,
          $$DatasetsTableCreateCompanionBuilder,
          $$DatasetsTableUpdateCompanionBuilder,
          (Dataset, $$DatasetsTableReferences),
          Dataset,
          PrefetchHooks Function({bool projectId})
        > {
  $$DatasetsTableTableManager(_$AppDatabase db, $DatasetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$DatasetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$DatasetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$DatasetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DatasetsCompanion(
                id: id,
                projectId: projectId,
                name: name,
                description: description,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required int projectId,
                required String name,
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DatasetsCompanion.insert(
                id: id,
                projectId: projectId,
                name: name,
                description: description,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          $$DatasetsTableReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: ({projectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                T extends TableManagerState<
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic,
                  dynamic
                >
              >(state) {
                if (projectId) {
                  state =
                      state.withJoin(
                            currentTable: table,
                            currentColumn: table.projectId,
                            referencedTable: $$DatasetsTableReferences
                                ._projectIdTable(db),
                            referencedColumn:
                                $$DatasetsTableReferences
                                    ._projectIdTable(db)
                                    .id,
                          )
                          as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DatasetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DatasetsTable,
      Dataset,
      $$DatasetsTableFilterComposer,
      $$DatasetsTableOrderingComposer,
      $$DatasetsTableAnnotationComposer,
      $$DatasetsTableCreateCompanionBuilder,
      $$DatasetsTableUpdateCompanionBuilder,
      (Dataset, $$DatasetsTableReferences),
      Dataset,
      PrefetchHooks Function({bool projectId})
    >;
typedef $$MediaItemsTableCreateCompanionBuilder =
    MediaItemsCompanion Function({
      Value<String?> id,
      required String datasetId,
      required String filePath,
      required MediaType type,
      required DateTime uploadDate,
      required String owner,
      Value<String?> lastAnnotator,
      Value<DateTime?> lastAnnotatedDate,
      Value<int?> numberOfFrames,
      Value<int> rowid,
    });
typedef $$MediaItemsTableUpdateCompanionBuilder =
    MediaItemsCompanion Function({
      Value<String?> id,
      Value<String> datasetId,
      Value<String> filePath,
      Value<MediaType> type,
      Value<DateTime> uploadDate,
      Value<String> owner,
      Value<String?> lastAnnotator,
      Value<DateTime?> lastAnnotatedDate,
      Value<int?> numberOfFrames,
      Value<int> rowid,
    });

class $$MediaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get datasetId => $composableBuilder(
    column: $table.datasetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MediaType, MediaType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get uploadDate => $composableBuilder(
    column: $table.uploadDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastAnnotator => $composableBuilder(
    column: $table.lastAnnotator,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAnnotatedDate => $composableBuilder(
    column: $table.lastAnnotatedDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get numberOfFrames => $composableBuilder(
    column: $table.numberOfFrames,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MediaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get datasetId => $composableBuilder(
    column: $table.datasetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get uploadDate => $composableBuilder(
    column: $table.uploadDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get owner => $composableBuilder(
    column: $table.owner,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastAnnotator => $composableBuilder(
    column: $table.lastAnnotator,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAnnotatedDate => $composableBuilder(
    column: $table.lastAnnotatedDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get numberOfFrames => $composableBuilder(
    column: $table.numberOfFrames,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get datasetId =>
      $composableBuilder(column: $table.datasetId, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediaType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<DateTime> get uploadDate => $composableBuilder(
    column: $table.uploadDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get owner =>
      $composableBuilder(column: $table.owner, builder: (column) => column);

  GeneratedColumn<String> get lastAnnotator => $composableBuilder(
    column: $table.lastAnnotator,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAnnotatedDate => $composableBuilder(
    column: $table.lastAnnotatedDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get numberOfFrames => $composableBuilder(
    column: $table.numberOfFrames,
    builder: (column) => column,
  );
}

class $$MediaItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaItemsTable,
          MediaItem,
          $$MediaItemsTableFilterComposer,
          $$MediaItemsTableOrderingComposer,
          $$MediaItemsTableAnnotationComposer,
          $$MediaItemsTableCreateCompanionBuilder,
          $$MediaItemsTableUpdateCompanionBuilder,
          (
            MediaItem,
            BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItem>,
          ),
          MediaItem,
          PrefetchHooks Function()
        > {
  $$MediaItemsTableTableManager(_$AppDatabase db, $MediaItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer:
              () => $$MediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer:
              () => $$MediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer:
              () => $$MediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String?> id = const Value.absent(),
                Value<String> datasetId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<MediaType> type = const Value.absent(),
                Value<DateTime> uploadDate = const Value.absent(),
                Value<String> owner = const Value.absent(),
                Value<String?> lastAnnotator = const Value.absent(),
                Value<DateTime?> lastAnnotatedDate = const Value.absent(),
                Value<int?> numberOfFrames = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaItemsCompanion(
                id: id,
                datasetId: datasetId,
                filePath: filePath,
                type: type,
                uploadDate: uploadDate,
                owner: owner,
                lastAnnotator: lastAnnotator,
                lastAnnotatedDate: lastAnnotatedDate,
                numberOfFrames: numberOfFrames,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<String?> id = const Value.absent(),
                required String datasetId,
                required String filePath,
                required MediaType type,
                required DateTime uploadDate,
                required String owner,
                Value<String?> lastAnnotator = const Value.absent(),
                Value<DateTime?> lastAnnotatedDate = const Value.absent(),
                Value<int?> numberOfFrames = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MediaItemsCompanion.insert(
                id: id,
                datasetId: datasetId,
                filePath: filePath,
                type: type,
                uploadDate: uploadDate,
                owner: owner,
                lastAnnotator: lastAnnotator,
                lastAnnotatedDate: lastAnnotatedDate,
                numberOfFrames: numberOfFrames,
                rowid: rowid,
              ),
          withReferenceMapper:
              (p0) =>
                  p0
                      .map(
                        (e) => (
                          e.readTable(table),
                          BaseReferences(db, table, e),
                        ),
                      )
                      .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MediaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaItemsTable,
      MediaItem,
      $$MediaItemsTableFilterComposer,
      $$MediaItemsTableOrderingComposer,
      $$MediaItemsTableAnnotationComposer,
      $$MediaItemsTableCreateCompanionBuilder,
      $$MediaItemsTableUpdateCompanionBuilder,
      (MediaItem, BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItem>),
      MediaItem,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$UsersTableTableManager get users =>
      $$UsersTableTableManager(_db, _db.users);
  $$ProjectsTableTableManager get projects =>
      $$ProjectsTableTableManager(_db, _db.projects);
  $$DatasetsTableTableManager get datasets =>
      $$DatasetsTableTableManager(_db, _db.datasets);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db, _db.mediaItems);
}
