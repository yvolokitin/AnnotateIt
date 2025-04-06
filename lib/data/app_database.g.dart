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
  static const VerificationMeta _darkModeMeta = const VerificationMeta(
    'darkMode',
  );
  @override
  late final GeneratedColumn<bool> darkMode = GeneratedColumn<bool>(
    'dark_mode',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("dark_mode" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    darkMode,
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
    if (data.containsKey('dark_mode')) {
      context.handle(
        _darkModeMeta,
        darkMode.isAcceptableOrUnknown(data['dark_mode']!, _darkModeMeta),
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
      darkMode:
          attachedDatabase.typeMapping.read(
            DriftSqlType.bool,
            data['${effectivePrefix}dark_mode'],
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
  final bool darkMode;
  const User({
    required this.id,
    required this.name,
    this.lastName,
    this.email,
    this.iconPath,
    this.datasetsFolderPath,
    this.thumbnailsFolderPath,
    required this.darkMode,
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
    map['dark_mode'] = Variable<bool>(darkMode);
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
      darkMode: Value(darkMode),
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
      darkMode: serializer.fromJson<bool>(json['darkMode']),
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
      'darkMode': serializer.toJson<bool>(darkMode),
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
    bool? darkMode,
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
    darkMode: darkMode ?? this.darkMode,
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
      darkMode: data.darkMode.present ? data.darkMode.value : this.darkMode,
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
          ..write('darkMode: $darkMode')
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
    darkMode,
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
          other.darkMode == this.darkMode);
}

class UsersCompanion extends UpdateCompanion<User> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> lastName;
  final Value<String?> email;
  final Value<String?> iconPath;
  final Value<String?> datasetsFolderPath;
  final Value<String?> thumbnailsFolderPath;
  final Value<bool> darkMode;
  const UsersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.lastName = const Value.absent(),
    this.email = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.datasetsFolderPath = const Value.absent(),
    this.thumbnailsFolderPath = const Value.absent(),
    this.darkMode = const Value.absent(),
  });
  UsersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.lastName = const Value.absent(),
    this.email = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.datasetsFolderPath = const Value.absent(),
    this.thumbnailsFolderPath = const Value.absent(),
    this.darkMode = const Value.absent(),
  }) : name = Value(name);
  static Insertable<User> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? lastName,
    Expression<String>? email,
    Expression<String>? iconPath,
    Expression<String>? datasetsFolderPath,
    Expression<String>? thumbnailsFolderPath,
    Expression<bool>? darkMode,
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
      if (darkMode != null) 'dark_mode': darkMode,
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
    Value<bool>? darkMode,
  }) {
    return UsersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      iconPath: iconPath ?? this.iconPath,
      datasetsFolderPath: datasetsFolderPath ?? this.datasetsFolderPath,
      thumbnailsFolderPath: thumbnailsFolderPath ?? this.thumbnailsFolderPath,
      darkMode: darkMode ?? this.darkMode,
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
    if (darkMode.present) {
      map['dark_mode'] = Variable<bool>(darkMode.value);
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
          ..write('darkMode: $darkMode')
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
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    iconPath,
    createdAt,
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
    if (data.containsKey('icon_path')) {
      context.handle(
        _iconPathMeta,
        iconPath.isAcceptableOrUnknown(data['icon_path']!, _iconPathMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
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
      iconPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}icon_path'],
      ),
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
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
  final String? iconPath;
  final DateTime createdAt;
  final int ownerId;
  const Project({
    required this.id,
    required this.name,
    this.iconPath,
    required this.createdAt,
    required this.ownerId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || iconPath != null) {
      map['icon_path'] = Variable<String>(iconPath);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['owner_id'] = Variable<int>(ownerId);
    return map;
  }

  ProjectsCompanion toCompanion(bool nullToAbsent) {
    return ProjectsCompanion(
      id: Value(id),
      name: Value(name),
      iconPath:
          iconPath == null && nullToAbsent
              ? const Value.absent()
              : Value(iconPath),
      createdAt: Value(createdAt),
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
      iconPath: serializer.fromJson<String?>(json['iconPath']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      ownerId: serializer.fromJson<int>(json['ownerId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'iconPath': serializer.toJson<String?>(iconPath),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'ownerId': serializer.toJson<int>(ownerId),
    };
  }

  Project copyWith({
    int? id,
    String? name,
    Value<String?> iconPath = const Value.absent(),
    DateTime? createdAt,
    int? ownerId,
  }) => Project(
    id: id ?? this.id,
    name: name ?? this.name,
    iconPath: iconPath.present ? iconPath.value : this.iconPath,
    createdAt: createdAt ?? this.createdAt,
    ownerId: ownerId ?? this.ownerId,
  );
  Project copyWithCompanion(ProjectsCompanion data) {
    return Project(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      iconPath: data.iconPath.present ? data.iconPath.value : this.iconPath,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      ownerId: data.ownerId.present ? data.ownerId.value : this.ownerId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Project(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('iconPath: $iconPath, ')
          ..write('createdAt: $createdAt, ')
          ..write('ownerId: $ownerId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, iconPath, createdAt, ownerId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Project &&
          other.id == this.id &&
          other.name == this.name &&
          other.iconPath == this.iconPath &&
          other.createdAt == this.createdAt &&
          other.ownerId == this.ownerId);
}

class ProjectsCompanion extends UpdateCompanion<Project> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> iconPath;
  final Value<DateTime> createdAt;
  final Value<int> ownerId;
  const ProjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.iconPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.ownerId = const Value.absent(),
  });
  ProjectsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.iconPath = const Value.absent(),
    this.createdAt = const Value.absent(),
    required int ownerId,
  }) : name = Value(name),
       ownerId = Value(ownerId);
  static Insertable<Project> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? iconPath,
    Expression<DateTime>? createdAt,
    Expression<int>? ownerId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (iconPath != null) 'icon_path': iconPath,
      if (createdAt != null) 'created_at': createdAt,
      if (ownerId != null) 'owner_id': ownerId,
    });
  }

  ProjectsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? iconPath,
    Value<DateTime>? createdAt,
    Value<int>? ownerId,
  }) {
    return ProjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      createdAt: createdAt ?? this.createdAt,
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
    if (iconPath.present) {
      map['icon_path'] = Variable<String>(iconPath.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
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
          ..write('iconPath: $iconPath, ')
          ..write('createdAt: $createdAt, ')
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
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    projectId,
    createdAt,
    description,
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
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('project_id')) {
      context.handle(
        _projectIdMeta,
        projectId.isAcceptableOrUnknown(data['project_id']!, _projectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_projectIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
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
            DriftSqlType.int,
            data['${effectivePrefix}id'],
          )!,
      name:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}name'],
          )!,
      projectId:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}project_id'],
          )!,
      createdAt:
          attachedDatabase.typeMapping.read(
            DriftSqlType.dateTime,
            data['${effectivePrefix}created_at'],
          )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
    );
  }

  @override
  $DatasetsTable createAlias(String alias) {
    return $DatasetsTable(attachedDatabase, alias);
  }
}

class Dataset extends DataClass implements Insertable<Dataset> {
  final int id;
  final String name;
  final int projectId;
  final DateTime createdAt;
  final String? description;
  const Dataset({
    required this.id,
    required this.name,
    required this.projectId,
    required this.createdAt,
    this.description,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['project_id'] = Variable<int>(projectId);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    return map;
  }

  DatasetsCompanion toCompanion(bool nullToAbsent) {
    return DatasetsCompanion(
      id: Value(id),
      name: Value(name),
      projectId: Value(projectId),
      createdAt: Value(createdAt),
      description:
          description == null && nullToAbsent
              ? const Value.absent()
              : Value(description),
    );
  }

  factory Dataset.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Dataset(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      projectId: serializer.fromJson<int>(json['projectId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      description: serializer.fromJson<String?>(json['description']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'projectId': serializer.toJson<int>(projectId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'description': serializer.toJson<String?>(description),
    };
  }

  Dataset copyWith({
    int? id,
    String? name,
    int? projectId,
    DateTime? createdAt,
    Value<String?> description = const Value.absent(),
  }) => Dataset(
    id: id ?? this.id,
    name: name ?? this.name,
    projectId: projectId ?? this.projectId,
    createdAt: createdAt ?? this.createdAt,
    description: description.present ? description.value : this.description,
  );
  Dataset copyWithCompanion(DatasetsCompanion data) {
    return Dataset(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      projectId: data.projectId.present ? data.projectId.value : this.projectId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      description:
          data.description.present ? data.description.value : this.description,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Dataset(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('projectId: $projectId, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, projectId, createdAt, description);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Dataset &&
          other.id == this.id &&
          other.name == this.name &&
          other.projectId == this.projectId &&
          other.createdAt == this.createdAt &&
          other.description == this.description);
}

class DatasetsCompanion extends UpdateCompanion<Dataset> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> projectId;
  final Value<DateTime> createdAt;
  final Value<String?> description;
  const DatasetsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.projectId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.description = const Value.absent(),
  });
  DatasetsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required int projectId,
    this.createdAt = const Value.absent(),
    this.description = const Value.absent(),
  }) : name = Value(name),
       projectId = Value(projectId);
  static Insertable<Dataset> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? projectId,
    Expression<DateTime>? createdAt,
    Expression<String>? description,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (projectId != null) 'project_id': projectId,
      if (createdAt != null) 'created_at': createdAt,
      if (description != null) 'description': description,
    });
  }

  DatasetsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<int>? projectId,
    Value<DateTime>? createdAt,
    Value<String?>? description,
  }) {
    return DatasetsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      projectId: projectId ?? this.projectId,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
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
    if (projectId.present) {
      map['project_id'] = Variable<int>(projectId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DatasetsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('projectId: $projectId, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description')
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
  late final GeneratedColumn<int> datasetId = GeneratedColumn<int>(
    'dataset_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
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
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<int> type = GeneratedColumn<int>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
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
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
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
            DriftSqlType.int,
            data['${effectivePrefix}dataset_id'],
          )!,
      filePath:
          attachedDatabase.typeMapping.read(
            DriftSqlType.string,
            data['${effectivePrefix}file_path'],
          )!,
      type:
          attachedDatabase.typeMapping.read(
            DriftSqlType.int,
            data['${effectivePrefix}type'],
          )!,
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
}

class MediaItem extends DataClass implements Insertable<MediaItem> {
  final String? id;
  final int datasetId;
  final String filePath;
  final int type;
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
    map['dataset_id'] = Variable<int>(datasetId);
    map['file_path'] = Variable<String>(filePath);
    map['type'] = Variable<int>(type);
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
      datasetId: serializer.fromJson<int>(json['datasetId']),
      filePath: serializer.fromJson<String>(json['filePath']),
      type: serializer.fromJson<int>(json['type']),
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
      'datasetId': serializer.toJson<int>(datasetId),
      'filePath': serializer.toJson<String>(filePath),
      'type': serializer.toJson<int>(type),
      'uploadDate': serializer.toJson<DateTime>(uploadDate),
      'owner': serializer.toJson<String>(owner),
      'lastAnnotator': serializer.toJson<String?>(lastAnnotator),
      'lastAnnotatedDate': serializer.toJson<DateTime?>(lastAnnotatedDate),
      'numberOfFrames': serializer.toJson<int?>(numberOfFrames),
    };
  }

  MediaItem copyWith({
    Value<String?> id = const Value.absent(),
    int? datasetId,
    String? filePath,
    int? type,
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
  final Value<int> datasetId;
  final Value<String> filePath;
  final Value<int> type;
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
    required int datasetId,
    required String filePath,
    required int type,
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
    Expression<int>? datasetId,
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
    Value<int>? datasetId,
    Value<String>? filePath,
    Value<int>? type,
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
      map['dataset_id'] = Variable<int>(datasetId.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(type.value);
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
      Value<bool> darkMode,
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
      Value<bool> darkMode,
    });

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

  ColumnFilters<bool> get darkMode => $composableBuilder(
    column: $table.darkMode,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<bool> get darkMode => $composableBuilder(
    column: $table.darkMode,
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

  GeneratedColumn<bool> get darkMode =>
      $composableBuilder(column: $table.darkMode, builder: (column) => column);
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
          (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
          User,
          PrefetchHooks Function()
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
                Value<bool> darkMode = const Value.absent(),
              }) => UsersCompanion(
                id: id,
                name: name,
                lastName: lastName,
                email: email,
                iconPath: iconPath,
                datasetsFolderPath: datasetsFolderPath,
                thumbnailsFolderPath: thumbnailsFolderPath,
                darkMode: darkMode,
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
                Value<bool> darkMode = const Value.absent(),
              }) => UsersCompanion.insert(
                id: id,
                name: name,
                lastName: lastName,
                email: email,
                iconPath: iconPath,
                datasetsFolderPath: datasetsFolderPath,
                thumbnailsFolderPath: thumbnailsFolderPath,
                darkMode: darkMode,
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
      (User, BaseReferences<_$AppDatabase, $UsersTable, User>),
      User,
      PrefetchHooks Function()
    >;
typedef $$ProjectsTableCreateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> iconPath,
      Value<DateTime> createdAt,
      required int ownerId,
    });
typedef $$ProjectsTableUpdateCompanionBuilder =
    ProjectsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> iconPath,
      Value<DateTime> createdAt,
      Value<int> ownerId,
    });

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

  ColumnFilters<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<String> get iconPath => $composableBuilder(
    column: $table.iconPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ownerId => $composableBuilder(
    column: $table.ownerId,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<String> get iconPath =>
      $composableBuilder(column: $table.iconPath, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get ownerId =>
      $composableBuilder(column: $table.ownerId, builder: (column) => column);
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
          (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
          Project,
          PrefetchHooks Function()
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
                Value<String?> iconPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> ownerId = const Value.absent(),
              }) => ProjectsCompanion(
                id: id,
                name: name,
                iconPath: iconPath,
                createdAt: createdAt,
                ownerId: ownerId,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> iconPath = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                required int ownerId,
              }) => ProjectsCompanion.insert(
                id: id,
                name: name,
                iconPath: iconPath,
                createdAt: createdAt,
                ownerId: ownerId,
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
      (Project, BaseReferences<_$AppDatabase, $ProjectsTable, Project>),
      Project,
      PrefetchHooks Function()
    >;
typedef $$DatasetsTableCreateCompanionBuilder =
    DatasetsCompanion Function({
      Value<int> id,
      required String name,
      required int projectId,
      Value<DateTime> createdAt,
      Value<String?> description,
    });
typedef $$DatasetsTableUpdateCompanionBuilder =
    DatasetsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<int> projectId,
      Value<DateTime> createdAt,
      Value<String?> description,
    });

class $$DatasetsTableFilterComposer
    extends Composer<_$AppDatabase, $DatasetsTable> {
  $$DatasetsTableFilterComposer({
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

  ColumnFilters<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get projectId => $composableBuilder(
    column: $table.projectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get projectId =>
      $composableBuilder(column: $table.projectId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );
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
          (Dataset, BaseReferences<_$AppDatabase, $DatasetsTable, Dataset>),
          Dataset,
          PrefetchHooks Function()
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
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> projectId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => DatasetsCompanion(
                id: id,
                name: name,
                projectId: projectId,
                createdAt: createdAt,
                description: description,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required int projectId,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> description = const Value.absent(),
              }) => DatasetsCompanion.insert(
                id: id,
                name: name,
                projectId: projectId,
                createdAt: createdAt,
                description: description,
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
      (Dataset, BaseReferences<_$AppDatabase, $DatasetsTable, Dataset>),
      Dataset,
      PrefetchHooks Function()
    >;
typedef $$MediaItemsTableCreateCompanionBuilder =
    MediaItemsCompanion Function({
      Value<String?> id,
      required int datasetId,
      required String filePath,
      required int type,
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
      Value<int> datasetId,
      Value<String> filePath,
      Value<int> type,
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

  ColumnFilters<int> get datasetId => $composableBuilder(
    column: $table.datasetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
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

  ColumnOrderings<int> get datasetId => $composableBuilder(
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

  GeneratedColumn<int> get datasetId =>
      $composableBuilder(column: $table.datasetId, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get type =>
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
                Value<int> datasetId = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<int> type = const Value.absent(),
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
                required int datasetId,
                required String filePath,
                required int type,
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
