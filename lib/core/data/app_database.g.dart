// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $TokenizerModelsTable extends TokenizerModels
    with TableInfo<$TokenizerModelsTable, TokenizerModel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TokenizerModelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _fileNameMeta = const VerificationMeta(
    'fileName',
  );
  @override
  late final GeneratedColumn<String> fileName = GeneratedColumn<String>(
    'file_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _vocabularySizeMeta = const VerificationMeta(
    'vocabularySize',
  );
  @override
  late final GeneratedColumn<int> vocabularySize = GeneratedColumn<int>(
    'vocabulary_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetVocabularySizeMeta =
      const VerificationMeta('targetVocabularySize');
  @override
  late final GeneratedColumn<int> targetVocabularySize = GeneratedColumn<int>(
    'target_vocabulary_size',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mergesMeta = const VerificationMeta('merges');
  @override
  late final GeneratedColumn<int> merges = GeneratedColumn<int>(
    'merges',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _corpusBytesMeta = const VerificationMeta(
    'corpusBytes',
  );
  @override
  late final GeneratedColumn<int> corpusBytes = GeneratedColumn<int>(
    'corpus_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _corpusCharactersMeta = const VerificationMeta(
    'corpusCharacters',
  );
  @override
  late final GeneratedColumn<int> corpusCharacters = GeneratedColumn<int>(
    'corpus_characters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _trainingMillisecondsMeta =
      const VerificationMeta('trainingMilliseconds');
  @override
  late final GeneratedColumn<int> trainingMilliseconds = GeneratedColumn<int>(
    'training_milliseconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fileBytesMeta = const VerificationMeta(
    'fileBytes',
  );
  @override
  late final GeneratedColumn<int> fileBytes = GeneratedColumn<int>(
    'file_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minPairFrequencyMeta = const VerificationMeta(
    'minPairFrequency',
  );
  @override
  late final GeneratedColumn<int> minPairFrequency = GeneratedColumn<int>(
    'min_pair_frequency',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _embeddingDimensionsMeta =
      const VerificationMeta('embeddingDimensions');
  @override
  late final GeneratedColumn<int> embeddingDimensions = GeneratedColumn<int>(
    'embedding_dimensions',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesPerWeightMeta = const VerificationMeta(
    'bytesPerWeight',
  );
  @override
  late final GeneratedColumn<int> bytesPerWeight = GeneratedColumn<int>(
    'bytes_per_weight',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    fileName,
    createdAt,
    vocabularySize,
    targetVocabularySize,
    merges,
    corpusBytes,
    corpusCharacters,
    trainingMilliseconds,
    fileBytes,
    minPairFrequency,
    embeddingDimensions,
    bytesPerWeight,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tokenizer_models';
  @override
  VerificationContext validateIntegrity(
    Insertable<TokenizerModel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('file_name')) {
      context.handle(
        _fileNameMeta,
        fileName.isAcceptableOrUnknown(data['file_name']!, _fileNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fileNameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('vocabulary_size')) {
      context.handle(
        _vocabularySizeMeta,
        vocabularySize.isAcceptableOrUnknown(
          data['vocabulary_size']!,
          _vocabularySizeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_vocabularySizeMeta);
    }
    if (data.containsKey('target_vocabulary_size')) {
      context.handle(
        _targetVocabularySizeMeta,
        targetVocabularySize.isAcceptableOrUnknown(
          data['target_vocabulary_size']!,
          _targetVocabularySizeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetVocabularySizeMeta);
    }
    if (data.containsKey('merges')) {
      context.handle(
        _mergesMeta,
        merges.isAcceptableOrUnknown(data['merges']!, _mergesMeta),
      );
    } else if (isInserting) {
      context.missing(_mergesMeta);
    }
    if (data.containsKey('corpus_bytes')) {
      context.handle(
        _corpusBytesMeta,
        corpusBytes.isAcceptableOrUnknown(
          data['corpus_bytes']!,
          _corpusBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_corpusBytesMeta);
    }
    if (data.containsKey('corpus_characters')) {
      context.handle(
        _corpusCharactersMeta,
        corpusCharacters.isAcceptableOrUnknown(
          data['corpus_characters']!,
          _corpusCharactersMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_corpusCharactersMeta);
    }
    if (data.containsKey('training_milliseconds')) {
      context.handle(
        _trainingMillisecondsMeta,
        trainingMilliseconds.isAcceptableOrUnknown(
          data['training_milliseconds']!,
          _trainingMillisecondsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_trainingMillisecondsMeta);
    }
    if (data.containsKey('file_bytes')) {
      context.handle(
        _fileBytesMeta,
        fileBytes.isAcceptableOrUnknown(data['file_bytes']!, _fileBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_fileBytesMeta);
    }
    if (data.containsKey('min_pair_frequency')) {
      context.handle(
        _minPairFrequencyMeta,
        minPairFrequency.isAcceptableOrUnknown(
          data['min_pair_frequency']!,
          _minPairFrequencyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minPairFrequencyMeta);
    }
    if (data.containsKey('embedding_dimensions')) {
      context.handle(
        _embeddingDimensionsMeta,
        embeddingDimensions.isAcceptableOrUnknown(
          data['embedding_dimensions']!,
          _embeddingDimensionsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_embeddingDimensionsMeta);
    }
    if (data.containsKey('bytes_per_weight')) {
      context.handle(
        _bytesPerWeightMeta,
        bytesPerWeight.isAcceptableOrUnknown(
          data['bytes_per_weight']!,
          _bytesPerWeightMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bytesPerWeightMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TokenizerModel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TokenizerModel(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      fileName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      vocabularySize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vocabulary_size'],
      )!,
      targetVocabularySize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_vocabulary_size'],
      )!,
      merges: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}merges'],
      )!,
      corpusBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}corpus_bytes'],
      )!,
      corpusCharacters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}corpus_characters'],
      )!,
      trainingMilliseconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}training_milliseconds'],
      )!,
      fileBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}file_bytes'],
      )!,
      minPairFrequency: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_pair_frequency'],
      )!,
      embeddingDimensions: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}embedding_dimensions'],
      )!,
      bytesPerWeight: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_per_weight'],
      )!,
    );
  }

  @override
  $TokenizerModelsTable createAlias(String alias) {
    return $TokenizerModelsTable(attachedDatabase, alias);
  }
}

class TokenizerModel extends DataClass implements Insertable<TokenizerModel> {
  final String id;
  final String name;
  final String fileName;
  final DateTime createdAt;
  final int vocabularySize;
  final int targetVocabularySize;
  final int merges;
  final int corpusBytes;
  final int corpusCharacters;
  final int trainingMilliseconds;
  final int fileBytes;
  final int minPairFrequency;
  final int embeddingDimensions;
  final int bytesPerWeight;
  const TokenizerModel({
    required this.id,
    required this.name,
    required this.fileName,
    required this.createdAt,
    required this.vocabularySize,
    required this.targetVocabularySize,
    required this.merges,
    required this.corpusBytes,
    required this.corpusCharacters,
    required this.trainingMilliseconds,
    required this.fileBytes,
    required this.minPairFrequency,
    required this.embeddingDimensions,
    required this.bytesPerWeight,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['file_name'] = Variable<String>(fileName);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['vocabulary_size'] = Variable<int>(vocabularySize);
    map['target_vocabulary_size'] = Variable<int>(targetVocabularySize);
    map['merges'] = Variable<int>(merges);
    map['corpus_bytes'] = Variable<int>(corpusBytes);
    map['corpus_characters'] = Variable<int>(corpusCharacters);
    map['training_milliseconds'] = Variable<int>(trainingMilliseconds);
    map['file_bytes'] = Variable<int>(fileBytes);
    map['min_pair_frequency'] = Variable<int>(minPairFrequency);
    map['embedding_dimensions'] = Variable<int>(embeddingDimensions);
    map['bytes_per_weight'] = Variable<int>(bytesPerWeight);
    return map;
  }

  TokenizerModelsCompanion toCompanion(bool nullToAbsent) {
    return TokenizerModelsCompanion(
      id: Value(id),
      name: Value(name),
      fileName: Value(fileName),
      createdAt: Value(createdAt),
      vocabularySize: Value(vocabularySize),
      targetVocabularySize: Value(targetVocabularySize),
      merges: Value(merges),
      corpusBytes: Value(corpusBytes),
      corpusCharacters: Value(corpusCharacters),
      trainingMilliseconds: Value(trainingMilliseconds),
      fileBytes: Value(fileBytes),
      minPairFrequency: Value(minPairFrequency),
      embeddingDimensions: Value(embeddingDimensions),
      bytesPerWeight: Value(bytesPerWeight),
    );
  }

  factory TokenizerModel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TokenizerModel(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      fileName: serializer.fromJson<String>(json['fileName']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      vocabularySize: serializer.fromJson<int>(json['vocabularySize']),
      targetVocabularySize: serializer.fromJson<int>(
        json['targetVocabularySize'],
      ),
      merges: serializer.fromJson<int>(json['merges']),
      corpusBytes: serializer.fromJson<int>(json['corpusBytes']),
      corpusCharacters: serializer.fromJson<int>(json['corpusCharacters']),
      trainingMilliseconds: serializer.fromJson<int>(
        json['trainingMilliseconds'],
      ),
      fileBytes: serializer.fromJson<int>(json['fileBytes']),
      minPairFrequency: serializer.fromJson<int>(json['minPairFrequency']),
      embeddingDimensions: serializer.fromJson<int>(
        json['embeddingDimensions'],
      ),
      bytesPerWeight: serializer.fromJson<int>(json['bytesPerWeight']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'fileName': serializer.toJson<String>(fileName),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'vocabularySize': serializer.toJson<int>(vocabularySize),
      'targetVocabularySize': serializer.toJson<int>(targetVocabularySize),
      'merges': serializer.toJson<int>(merges),
      'corpusBytes': serializer.toJson<int>(corpusBytes),
      'corpusCharacters': serializer.toJson<int>(corpusCharacters),
      'trainingMilliseconds': serializer.toJson<int>(trainingMilliseconds),
      'fileBytes': serializer.toJson<int>(fileBytes),
      'minPairFrequency': serializer.toJson<int>(minPairFrequency),
      'embeddingDimensions': serializer.toJson<int>(embeddingDimensions),
      'bytesPerWeight': serializer.toJson<int>(bytesPerWeight),
    };
  }

  TokenizerModel copyWith({
    String? id,
    String? name,
    String? fileName,
    DateTime? createdAt,
    int? vocabularySize,
    int? targetVocabularySize,
    int? merges,
    int? corpusBytes,
    int? corpusCharacters,
    int? trainingMilliseconds,
    int? fileBytes,
    int? minPairFrequency,
    int? embeddingDimensions,
    int? bytesPerWeight,
  }) => TokenizerModel(
    id: id ?? this.id,
    name: name ?? this.name,
    fileName: fileName ?? this.fileName,
    createdAt: createdAt ?? this.createdAt,
    vocabularySize: vocabularySize ?? this.vocabularySize,
    targetVocabularySize: targetVocabularySize ?? this.targetVocabularySize,
    merges: merges ?? this.merges,
    corpusBytes: corpusBytes ?? this.corpusBytes,
    corpusCharacters: corpusCharacters ?? this.corpusCharacters,
    trainingMilliseconds: trainingMilliseconds ?? this.trainingMilliseconds,
    fileBytes: fileBytes ?? this.fileBytes,
    minPairFrequency: minPairFrequency ?? this.minPairFrequency,
    embeddingDimensions: embeddingDimensions ?? this.embeddingDimensions,
    bytesPerWeight: bytesPerWeight ?? this.bytesPerWeight,
  );
  TokenizerModel copyWithCompanion(TokenizerModelsCompanion data) {
    return TokenizerModel(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      fileName: data.fileName.present ? data.fileName.value : this.fileName,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      vocabularySize: data.vocabularySize.present
          ? data.vocabularySize.value
          : this.vocabularySize,
      targetVocabularySize: data.targetVocabularySize.present
          ? data.targetVocabularySize.value
          : this.targetVocabularySize,
      merges: data.merges.present ? data.merges.value : this.merges,
      corpusBytes: data.corpusBytes.present
          ? data.corpusBytes.value
          : this.corpusBytes,
      corpusCharacters: data.corpusCharacters.present
          ? data.corpusCharacters.value
          : this.corpusCharacters,
      trainingMilliseconds: data.trainingMilliseconds.present
          ? data.trainingMilliseconds.value
          : this.trainingMilliseconds,
      fileBytes: data.fileBytes.present ? data.fileBytes.value : this.fileBytes,
      minPairFrequency: data.minPairFrequency.present
          ? data.minPairFrequency.value
          : this.minPairFrequency,
      embeddingDimensions: data.embeddingDimensions.present
          ? data.embeddingDimensions.value
          : this.embeddingDimensions,
      bytesPerWeight: data.bytesPerWeight.present
          ? data.bytesPerWeight.value
          : this.bytesPerWeight,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TokenizerModel(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fileName: $fileName, ')
          ..write('createdAt: $createdAt, ')
          ..write('vocabularySize: $vocabularySize, ')
          ..write('targetVocabularySize: $targetVocabularySize, ')
          ..write('merges: $merges, ')
          ..write('corpusBytes: $corpusBytes, ')
          ..write('corpusCharacters: $corpusCharacters, ')
          ..write('trainingMilliseconds: $trainingMilliseconds, ')
          ..write('fileBytes: $fileBytes, ')
          ..write('minPairFrequency: $minPairFrequency, ')
          ..write('embeddingDimensions: $embeddingDimensions, ')
          ..write('bytesPerWeight: $bytesPerWeight')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    fileName,
    createdAt,
    vocabularySize,
    targetVocabularySize,
    merges,
    corpusBytes,
    corpusCharacters,
    trainingMilliseconds,
    fileBytes,
    minPairFrequency,
    embeddingDimensions,
    bytesPerWeight,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TokenizerModel &&
          other.id == this.id &&
          other.name == this.name &&
          other.fileName == this.fileName &&
          other.createdAt == this.createdAt &&
          other.vocabularySize == this.vocabularySize &&
          other.targetVocabularySize == this.targetVocabularySize &&
          other.merges == this.merges &&
          other.corpusBytes == this.corpusBytes &&
          other.corpusCharacters == this.corpusCharacters &&
          other.trainingMilliseconds == this.trainingMilliseconds &&
          other.fileBytes == this.fileBytes &&
          other.minPairFrequency == this.minPairFrequency &&
          other.embeddingDimensions == this.embeddingDimensions &&
          other.bytesPerWeight == this.bytesPerWeight);
}

class TokenizerModelsCompanion extends UpdateCompanion<TokenizerModel> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> fileName;
  final Value<DateTime> createdAt;
  final Value<int> vocabularySize;
  final Value<int> targetVocabularySize;
  final Value<int> merges;
  final Value<int> corpusBytes;
  final Value<int> corpusCharacters;
  final Value<int> trainingMilliseconds;
  final Value<int> fileBytes;
  final Value<int> minPairFrequency;
  final Value<int> embeddingDimensions;
  final Value<int> bytesPerWeight;
  final Value<int> rowid;
  const TokenizerModelsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.fileName = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.vocabularySize = const Value.absent(),
    this.targetVocabularySize = const Value.absent(),
    this.merges = const Value.absent(),
    this.corpusBytes = const Value.absent(),
    this.corpusCharacters = const Value.absent(),
    this.trainingMilliseconds = const Value.absent(),
    this.fileBytes = const Value.absent(),
    this.minPairFrequency = const Value.absent(),
    this.embeddingDimensions = const Value.absent(),
    this.bytesPerWeight = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TokenizerModelsCompanion.insert({
    required String id,
    required String name,
    required String fileName,
    required DateTime createdAt,
    required int vocabularySize,
    required int targetVocabularySize,
    required int merges,
    required int corpusBytes,
    required int corpusCharacters,
    required int trainingMilliseconds,
    required int fileBytes,
    required int minPairFrequency,
    required int embeddingDimensions,
    required int bytesPerWeight,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       fileName = Value(fileName),
       createdAt = Value(createdAt),
       vocabularySize = Value(vocabularySize),
       targetVocabularySize = Value(targetVocabularySize),
       merges = Value(merges),
       corpusBytes = Value(corpusBytes),
       corpusCharacters = Value(corpusCharacters),
       trainingMilliseconds = Value(trainingMilliseconds),
       fileBytes = Value(fileBytes),
       minPairFrequency = Value(minPairFrequency),
       embeddingDimensions = Value(embeddingDimensions),
       bytesPerWeight = Value(bytesPerWeight);
  static Insertable<TokenizerModel> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? fileName,
    Expression<DateTime>? createdAt,
    Expression<int>? vocabularySize,
    Expression<int>? targetVocabularySize,
    Expression<int>? merges,
    Expression<int>? corpusBytes,
    Expression<int>? corpusCharacters,
    Expression<int>? trainingMilliseconds,
    Expression<int>? fileBytes,
    Expression<int>? minPairFrequency,
    Expression<int>? embeddingDimensions,
    Expression<int>? bytesPerWeight,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (fileName != null) 'file_name': fileName,
      if (createdAt != null) 'created_at': createdAt,
      if (vocabularySize != null) 'vocabulary_size': vocabularySize,
      if (targetVocabularySize != null)
        'target_vocabulary_size': targetVocabularySize,
      if (merges != null) 'merges': merges,
      if (corpusBytes != null) 'corpus_bytes': corpusBytes,
      if (corpusCharacters != null) 'corpus_characters': corpusCharacters,
      if (trainingMilliseconds != null)
        'training_milliseconds': trainingMilliseconds,
      if (fileBytes != null) 'file_bytes': fileBytes,
      if (minPairFrequency != null) 'min_pair_frequency': minPairFrequency,
      if (embeddingDimensions != null)
        'embedding_dimensions': embeddingDimensions,
      if (bytesPerWeight != null) 'bytes_per_weight': bytesPerWeight,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TokenizerModelsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? fileName,
    Value<DateTime>? createdAt,
    Value<int>? vocabularySize,
    Value<int>? targetVocabularySize,
    Value<int>? merges,
    Value<int>? corpusBytes,
    Value<int>? corpusCharacters,
    Value<int>? trainingMilliseconds,
    Value<int>? fileBytes,
    Value<int>? minPairFrequency,
    Value<int>? embeddingDimensions,
    Value<int>? bytesPerWeight,
    Value<int>? rowid,
  }) {
    return TokenizerModelsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
      vocabularySize: vocabularySize ?? this.vocabularySize,
      targetVocabularySize: targetVocabularySize ?? this.targetVocabularySize,
      merges: merges ?? this.merges,
      corpusBytes: corpusBytes ?? this.corpusBytes,
      corpusCharacters: corpusCharacters ?? this.corpusCharacters,
      trainingMilliseconds: trainingMilliseconds ?? this.trainingMilliseconds,
      fileBytes: fileBytes ?? this.fileBytes,
      minPairFrequency: minPairFrequency ?? this.minPairFrequency,
      embeddingDimensions: embeddingDimensions ?? this.embeddingDimensions,
      bytesPerWeight: bytesPerWeight ?? this.bytesPerWeight,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (fileName.present) {
      map['file_name'] = Variable<String>(fileName.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (vocabularySize.present) {
      map['vocabulary_size'] = Variable<int>(vocabularySize.value);
    }
    if (targetVocabularySize.present) {
      map['target_vocabulary_size'] = Variable<int>(targetVocabularySize.value);
    }
    if (merges.present) {
      map['merges'] = Variable<int>(merges.value);
    }
    if (corpusBytes.present) {
      map['corpus_bytes'] = Variable<int>(corpusBytes.value);
    }
    if (corpusCharacters.present) {
      map['corpus_characters'] = Variable<int>(corpusCharacters.value);
    }
    if (trainingMilliseconds.present) {
      map['training_milliseconds'] = Variable<int>(trainingMilliseconds.value);
    }
    if (fileBytes.present) {
      map['file_bytes'] = Variable<int>(fileBytes.value);
    }
    if (minPairFrequency.present) {
      map['min_pair_frequency'] = Variable<int>(minPairFrequency.value);
    }
    if (embeddingDimensions.present) {
      map['embedding_dimensions'] = Variable<int>(embeddingDimensions.value);
    }
    if (bytesPerWeight.present) {
      map['bytes_per_weight'] = Variable<int>(bytesPerWeight.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TokenizerModelsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('fileName: $fileName, ')
          ..write('createdAt: $createdAt, ')
          ..write('vocabularySize: $vocabularySize, ')
          ..write('targetVocabularySize: $targetVocabularySize, ')
          ..write('merges: $merges, ')
          ..write('corpusBytes: $corpusBytes, ')
          ..write('corpusCharacters: $corpusCharacters, ')
          ..write('trainingMilliseconds: $trainingMilliseconds, ')
          ..write('fileBytes: $fileBytes, ')
          ..write('minPairFrequency: $minPairFrequency, ')
          ..write('embeddingDimensions: $embeddingDimensions, ')
          ..write('bytesPerWeight: $bytesPerWeight, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TrainingSourcesTable extends TrainingSources
    with TableInfo<$TrainingSourcesTable, TrainingSource> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrainingSourcesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _modelIdMeta = const VerificationMeta(
    'modelId',
  );
  @override
  late final GeneratedColumn<String> modelId = GeneratedColumn<String>(
    'model_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tokenizer_models (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
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
  static const VerificationMeta _bytesMeta = const VerificationMeta('bytes');
  @override
  late final GeneratedColumn<int> bytes = GeneratedColumn<int>(
    'bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _charactersMeta = const VerificationMeta(
    'characters',
  );
  @override
  late final GeneratedColumn<int> characters = GeneratedColumn<int>(
    'characters',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _linesMeta = const VerificationMeta('lines');
  @override
  late final GeneratedColumn<int> lines = GeneratedColumn<int>(
    'lines',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    modelId,
    position,
    name,
    bytes,
    characters,
    lines,
    contentHash,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'training_sources';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrainingSource> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('model_id')) {
      context.handle(
        _modelIdMeta,
        modelId.isAcceptableOrUnknown(data['model_id']!, _modelIdMeta),
      );
    } else if (isInserting) {
      context.missing(_modelIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('bytes')) {
      context.handle(
        _bytesMeta,
        bytes.isAcceptableOrUnknown(data['bytes']!, _bytesMeta),
      );
    } else if (isInserting) {
      context.missing(_bytesMeta);
    }
    if (data.containsKey('characters')) {
      context.handle(
        _charactersMeta,
        characters.isAcceptableOrUnknown(data['characters']!, _charactersMeta),
      );
    } else if (isInserting) {
      context.missing(_charactersMeta);
    }
    if (data.containsKey('lines')) {
      context.handle(
        _linesMeta,
        lines.isAcceptableOrUnknown(data['lines']!, _linesMeta),
      );
    } else if (isInserting) {
      context.missing(_linesMeta);
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_contentHashMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrainingSource map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrainingSource(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      modelId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      bytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes'],
      )!,
      characters: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}characters'],
      )!,
      lines: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}lines'],
      )!,
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      )!,
    );
  }

  @override
  $TrainingSourcesTable createAlias(String alias) {
    return $TrainingSourcesTable(attachedDatabase, alias);
  }
}

class TrainingSource extends DataClass implements Insertable<TrainingSource> {
  final int id;
  final String modelId;
  final int position;
  final String name;
  final int bytes;
  final int characters;
  final int lines;
  final String contentHash;
  const TrainingSource({
    required this.id,
    required this.modelId,
    required this.position,
    required this.name,
    required this.bytes,
    required this.characters,
    required this.lines,
    required this.contentHash,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['model_id'] = Variable<String>(modelId);
    map['position'] = Variable<int>(position);
    map['name'] = Variable<String>(name);
    map['bytes'] = Variable<int>(bytes);
    map['characters'] = Variable<int>(characters);
    map['lines'] = Variable<int>(lines);
    map['content_hash'] = Variable<String>(contentHash);
    return map;
  }

  TrainingSourcesCompanion toCompanion(bool nullToAbsent) {
    return TrainingSourcesCompanion(
      id: Value(id),
      modelId: Value(modelId),
      position: Value(position),
      name: Value(name),
      bytes: Value(bytes),
      characters: Value(characters),
      lines: Value(lines),
      contentHash: Value(contentHash),
    );
  }

  factory TrainingSource.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrainingSource(
      id: serializer.fromJson<int>(json['id']),
      modelId: serializer.fromJson<String>(json['modelId']),
      position: serializer.fromJson<int>(json['position']),
      name: serializer.fromJson<String>(json['name']),
      bytes: serializer.fromJson<int>(json['bytes']),
      characters: serializer.fromJson<int>(json['characters']),
      lines: serializer.fromJson<int>(json['lines']),
      contentHash: serializer.fromJson<String>(json['contentHash']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'modelId': serializer.toJson<String>(modelId),
      'position': serializer.toJson<int>(position),
      'name': serializer.toJson<String>(name),
      'bytes': serializer.toJson<int>(bytes),
      'characters': serializer.toJson<int>(characters),
      'lines': serializer.toJson<int>(lines),
      'contentHash': serializer.toJson<String>(contentHash),
    };
  }

  TrainingSource copyWith({
    int? id,
    String? modelId,
    int? position,
    String? name,
    int? bytes,
    int? characters,
    int? lines,
    String? contentHash,
  }) => TrainingSource(
    id: id ?? this.id,
    modelId: modelId ?? this.modelId,
    position: position ?? this.position,
    name: name ?? this.name,
    bytes: bytes ?? this.bytes,
    characters: characters ?? this.characters,
    lines: lines ?? this.lines,
    contentHash: contentHash ?? this.contentHash,
  );
  TrainingSource copyWithCompanion(TrainingSourcesCompanion data) {
    return TrainingSource(
      id: data.id.present ? data.id.value : this.id,
      modelId: data.modelId.present ? data.modelId.value : this.modelId,
      position: data.position.present ? data.position.value : this.position,
      name: data.name.present ? data.name.value : this.name,
      bytes: data.bytes.present ? data.bytes.value : this.bytes,
      characters: data.characters.present
          ? data.characters.value
          : this.characters,
      lines: data.lines.present ? data.lines.value : this.lines,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrainingSource(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('bytes: $bytes, ')
          ..write('characters: $characters, ')
          ..write('lines: $lines, ')
          ..write('contentHash: $contentHash')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    modelId,
    position,
    name,
    bytes,
    characters,
    lines,
    contentHash,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrainingSource &&
          other.id == this.id &&
          other.modelId == this.modelId &&
          other.position == this.position &&
          other.name == this.name &&
          other.bytes == this.bytes &&
          other.characters == this.characters &&
          other.lines == this.lines &&
          other.contentHash == this.contentHash);
}

class TrainingSourcesCompanion extends UpdateCompanion<TrainingSource> {
  final Value<int> id;
  final Value<String> modelId;
  final Value<int> position;
  final Value<String> name;
  final Value<int> bytes;
  final Value<int> characters;
  final Value<int> lines;
  final Value<String> contentHash;
  const TrainingSourcesCompanion({
    this.id = const Value.absent(),
    this.modelId = const Value.absent(),
    this.position = const Value.absent(),
    this.name = const Value.absent(),
    this.bytes = const Value.absent(),
    this.characters = const Value.absent(),
    this.lines = const Value.absent(),
    this.contentHash = const Value.absent(),
  });
  TrainingSourcesCompanion.insert({
    this.id = const Value.absent(),
    required String modelId,
    required int position,
    required String name,
    required int bytes,
    required int characters,
    required int lines,
    required String contentHash,
  }) : modelId = Value(modelId),
       position = Value(position),
       name = Value(name),
       bytes = Value(bytes),
       characters = Value(characters),
       lines = Value(lines),
       contentHash = Value(contentHash);
  static Insertable<TrainingSource> custom({
    Expression<int>? id,
    Expression<String>? modelId,
    Expression<int>? position,
    Expression<String>? name,
    Expression<int>? bytes,
    Expression<int>? characters,
    Expression<int>? lines,
    Expression<String>? contentHash,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (modelId != null) 'model_id': modelId,
      if (position != null) 'position': position,
      if (name != null) 'name': name,
      if (bytes != null) 'bytes': bytes,
      if (characters != null) 'characters': characters,
      if (lines != null) 'lines': lines,
      if (contentHash != null) 'content_hash': contentHash,
    });
  }

  TrainingSourcesCompanion copyWith({
    Value<int>? id,
    Value<String>? modelId,
    Value<int>? position,
    Value<String>? name,
    Value<int>? bytes,
    Value<int>? characters,
    Value<int>? lines,
    Value<String>? contentHash,
  }) {
    return TrainingSourcesCompanion(
      id: id ?? this.id,
      modelId: modelId ?? this.modelId,
      position: position ?? this.position,
      name: name ?? this.name,
      bytes: bytes ?? this.bytes,
      characters: characters ?? this.characters,
      lines: lines ?? this.lines,
      contentHash: contentHash ?? this.contentHash,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (modelId.present) {
      map['model_id'] = Variable<String>(modelId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (bytes.present) {
      map['bytes'] = Variable<int>(bytes.value);
    }
    if (characters.present) {
      map['characters'] = Variable<int>(characters.value);
    }
    if (lines.present) {
      map['lines'] = Variable<int>(lines.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrainingSourcesCompanion(')
          ..write('id: $id, ')
          ..write('modelId: $modelId, ')
          ..write('position: $position, ')
          ..write('name: $name, ')
          ..write('bytes: $bytes, ')
          ..write('characters: $characters, ')
          ..write('lines: $lines, ')
          ..write('contentHash: $contentHash')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TokenizerModelsTable tokenizerModels = $TokenizerModelsTable(
    this,
  );
  late final $TrainingSourcesTable trainingSources = $TrainingSourcesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    tokenizerModels,
    trainingSources,
  ];
}

typedef $$TokenizerModelsTableCreateCompanionBuilder =
    TokenizerModelsCompanion Function({
      required String id,
      required String name,
      required String fileName,
      required DateTime createdAt,
      required int vocabularySize,
      required int targetVocabularySize,
      required int merges,
      required int corpusBytes,
      required int corpusCharacters,
      required int trainingMilliseconds,
      required int fileBytes,
      required int minPairFrequency,
      required int embeddingDimensions,
      required int bytesPerWeight,
      Value<int> rowid,
    });
typedef $$TokenizerModelsTableUpdateCompanionBuilder =
    TokenizerModelsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> fileName,
      Value<DateTime> createdAt,
      Value<int> vocabularySize,
      Value<int> targetVocabularySize,
      Value<int> merges,
      Value<int> corpusBytes,
      Value<int> corpusCharacters,
      Value<int> trainingMilliseconds,
      Value<int> fileBytes,
      Value<int> minPairFrequency,
      Value<int> embeddingDimensions,
      Value<int> bytesPerWeight,
      Value<int> rowid,
    });

final class $$TokenizerModelsTableReferences
    extends
        BaseReferences<_$AppDatabase, $TokenizerModelsTable, TokenizerModel> {
  $$TokenizerModelsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$TrainingSourcesTable, List<TrainingSource>>
  _trainingSourcesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.trainingSources,
    aliasName: 'tokenizer_models__id__training_sources__model_id',
  );

  $$TrainingSourcesTableProcessedTableManager get trainingSourcesRefs {
    final manager = $$TrainingSourcesTableTableManager(
      $_db,
      $_db.trainingSources,
    ).filter((f) => f.modelId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _trainingSourcesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TokenizerModelsTableFilterComposer
    extends Composer<_$AppDatabase, $TokenizerModelsTable> {
  $$TokenizerModelsTableFilterComposer({
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

  ColumnFilters<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vocabularySize => $composableBuilder(
    column: $table.vocabularySize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetVocabularySize => $composableBuilder(
    column: $table.targetVocabularySize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get merges => $composableBuilder(
    column: $table.merges,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get corpusBytes => $composableBuilder(
    column: $table.corpusBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get corpusCharacters => $composableBuilder(
    column: $table.corpusCharacters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get trainingMilliseconds => $composableBuilder(
    column: $table.trainingMilliseconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fileBytes => $composableBuilder(
    column: $table.fileBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minPairFrequency => $composableBuilder(
    column: $table.minPairFrequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get embeddingDimensions => $composableBuilder(
    column: $table.embeddingDimensions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesPerWeight => $composableBuilder(
    column: $table.bytesPerWeight,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> trainingSourcesRefs(
    Expression<bool> Function($$TrainingSourcesTableFilterComposer f) f,
  ) {
    final $$TrainingSourcesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trainingSources,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSourcesTableFilterComposer(
            $db: $db,
            $table: $db.trainingSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TokenizerModelsTableOrderingComposer
    extends Composer<_$AppDatabase, $TokenizerModelsTable> {
  $$TokenizerModelsTableOrderingComposer({
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

  ColumnOrderings<String> get fileName => $composableBuilder(
    column: $table.fileName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vocabularySize => $composableBuilder(
    column: $table.vocabularySize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetVocabularySize => $composableBuilder(
    column: $table.targetVocabularySize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get merges => $composableBuilder(
    column: $table.merges,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get corpusBytes => $composableBuilder(
    column: $table.corpusBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get corpusCharacters => $composableBuilder(
    column: $table.corpusCharacters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get trainingMilliseconds => $composableBuilder(
    column: $table.trainingMilliseconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fileBytes => $composableBuilder(
    column: $table.fileBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minPairFrequency => $composableBuilder(
    column: $table.minPairFrequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get embeddingDimensions => $composableBuilder(
    column: $table.embeddingDimensions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesPerWeight => $composableBuilder(
    column: $table.bytesPerWeight,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TokenizerModelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TokenizerModelsTable> {
  $$TokenizerModelsTableAnnotationComposer({
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

  GeneratedColumn<String> get fileName =>
      $composableBuilder(column: $table.fileName, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get vocabularySize => $composableBuilder(
    column: $table.vocabularySize,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetVocabularySize => $composableBuilder(
    column: $table.targetVocabularySize,
    builder: (column) => column,
  );

  GeneratedColumn<int> get merges =>
      $composableBuilder(column: $table.merges, builder: (column) => column);

  GeneratedColumn<int> get corpusBytes => $composableBuilder(
    column: $table.corpusBytes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get corpusCharacters => $composableBuilder(
    column: $table.corpusCharacters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get trainingMilliseconds => $composableBuilder(
    column: $table.trainingMilliseconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get fileBytes =>
      $composableBuilder(column: $table.fileBytes, builder: (column) => column);

  GeneratedColumn<int> get minPairFrequency => $composableBuilder(
    column: $table.minPairFrequency,
    builder: (column) => column,
  );

  GeneratedColumn<int> get embeddingDimensions => $composableBuilder(
    column: $table.embeddingDimensions,
    builder: (column) => column,
  );

  GeneratedColumn<int> get bytesPerWeight => $composableBuilder(
    column: $table.bytesPerWeight,
    builder: (column) => column,
  );

  Expression<T> trainingSourcesRefs<T extends Object>(
    Expression<T> Function($$TrainingSourcesTableAnnotationComposer a) f,
  ) {
    final $$TrainingSourcesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.trainingSources,
      getReferencedColumn: (t) => t.modelId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrainingSourcesTableAnnotationComposer(
            $db: $db,
            $table: $db.trainingSources,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TokenizerModelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TokenizerModelsTable,
          TokenizerModel,
          $$TokenizerModelsTableFilterComposer,
          $$TokenizerModelsTableOrderingComposer,
          $$TokenizerModelsTableAnnotationComposer,
          $$TokenizerModelsTableCreateCompanionBuilder,
          $$TokenizerModelsTableUpdateCompanionBuilder,
          (TokenizerModel, $$TokenizerModelsTableReferences),
          TokenizerModel,
          PrefetchHooks Function({bool trainingSourcesRefs})
        > {
  $$TokenizerModelsTableTableManager(
    _$AppDatabase db,
    $TokenizerModelsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TokenizerModelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TokenizerModelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TokenizerModelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> fileName = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> vocabularySize = const Value.absent(),
                Value<int> targetVocabularySize = const Value.absent(),
                Value<int> merges = const Value.absent(),
                Value<int> corpusBytes = const Value.absent(),
                Value<int> corpusCharacters = const Value.absent(),
                Value<int> trainingMilliseconds = const Value.absent(),
                Value<int> fileBytes = const Value.absent(),
                Value<int> minPairFrequency = const Value.absent(),
                Value<int> embeddingDimensions = const Value.absent(),
                Value<int> bytesPerWeight = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TokenizerModelsCompanion(
                id: id,
                name: name,
                fileName: fileName,
                createdAt: createdAt,
                vocabularySize: vocabularySize,
                targetVocabularySize: targetVocabularySize,
                merges: merges,
                corpusBytes: corpusBytes,
                corpusCharacters: corpusCharacters,
                trainingMilliseconds: trainingMilliseconds,
                fileBytes: fileBytes,
                minPairFrequency: minPairFrequency,
                embeddingDimensions: embeddingDimensions,
                bytesPerWeight: bytesPerWeight,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String fileName,
                required DateTime createdAt,
                required int vocabularySize,
                required int targetVocabularySize,
                required int merges,
                required int corpusBytes,
                required int corpusCharacters,
                required int trainingMilliseconds,
                required int fileBytes,
                required int minPairFrequency,
                required int embeddingDimensions,
                required int bytesPerWeight,
                Value<int> rowid = const Value.absent(),
              }) => TokenizerModelsCompanion.insert(
                id: id,
                name: name,
                fileName: fileName,
                createdAt: createdAt,
                vocabularySize: vocabularySize,
                targetVocabularySize: targetVocabularySize,
                merges: merges,
                corpusBytes: corpusBytes,
                corpusCharacters: corpusCharacters,
                trainingMilliseconds: trainingMilliseconds,
                fileBytes: fileBytes,
                minPairFrequency: minPairFrequency,
                embeddingDimensions: embeddingDimensions,
                bytesPerWeight: bytesPerWeight,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TokenizerModelsTable, TokenizerModel>(table),
                  $$TokenizerModelsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({trainingSourcesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (trainingSourcesRefs) db.trainingSources,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (trainingSourcesRefs)
                    await $_getPrefetchedData<
                      TokenizerModel,
                      $TokenizerModelsTable,
                      TrainingSource
                    >(
                      currentTable: table,
                      referencedTable: $$TokenizerModelsTableReferences
                          ._trainingSourcesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TokenizerModelsTableReferences(
                            db,
                            table,
                            p0,
                          ).trainingSourcesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.modelId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TokenizerModelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TokenizerModelsTable,
      TokenizerModel,
      $$TokenizerModelsTableFilterComposer,
      $$TokenizerModelsTableOrderingComposer,
      $$TokenizerModelsTableAnnotationComposer,
      $$TokenizerModelsTableCreateCompanionBuilder,
      $$TokenizerModelsTableUpdateCompanionBuilder,
      (TokenizerModel, $$TokenizerModelsTableReferences),
      TokenizerModel,
      PrefetchHooks Function({bool trainingSourcesRefs})
    >;
typedef $$TrainingSourcesTableCreateCompanionBuilder =
    TrainingSourcesCompanion Function({
      Value<int> id,
      required String modelId,
      required int position,
      required String name,
      required int bytes,
      required int characters,
      required int lines,
      required String contentHash,
    });
typedef $$TrainingSourcesTableUpdateCompanionBuilder =
    TrainingSourcesCompanion Function({
      Value<int> id,
      Value<String> modelId,
      Value<int> position,
      Value<String> name,
      Value<int> bytes,
      Value<int> characters,
      Value<int> lines,
      Value<String> contentHash,
    });

final class $$TrainingSourcesTableReferences
    extends
        BaseReferences<_$AppDatabase, $TrainingSourcesTable, TrainingSource> {
  $$TrainingSourcesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TokenizerModelsTable _modelIdTable(_$AppDatabase db) => db
      .tokenizerModels
      .createAlias('training_sources__model_id__tokenizer_models__id');

  $$TokenizerModelsTableProcessedTableManager get modelId {
    final $_column = $_itemColumn<String>('model_id')!;

    final manager = $$TokenizerModelsTableTableManager(
      $_db,
      $_db.tokenizerModels,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_modelIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TrainingSourcesTableFilterComposer
    extends Composer<_$AppDatabase, $TrainingSourcesTable> {
  $$TrainingSourcesTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get characters => $composableBuilder(
    column: $table.characters,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lines => $composableBuilder(
    column: $table.lines,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  $$TokenizerModelsTableFilterComposer get modelId {
    final $$TokenizerModelsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.tokenizerModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokenizerModelsTableFilterComposer(
            $db: $db,
            $table: $db.tokenizerModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrainingSourcesTableOrderingComposer
    extends Composer<_$AppDatabase, $TrainingSourcesTable> {
  $$TrainingSourcesTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytes => $composableBuilder(
    column: $table.bytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get characters => $composableBuilder(
    column: $table.characters,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lines => $composableBuilder(
    column: $table.lines,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  $$TokenizerModelsTableOrderingComposer get modelId {
    final $$TokenizerModelsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.tokenizerModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokenizerModelsTableOrderingComposer(
            $db: $db,
            $table: $db.tokenizerModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrainingSourcesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrainingSourcesTable> {
  $$TrainingSourcesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get bytes =>
      $composableBuilder(column: $table.bytes, builder: (column) => column);

  GeneratedColumn<int> get characters => $composableBuilder(
    column: $table.characters,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lines =>
      $composableBuilder(column: $table.lines, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  $$TokenizerModelsTableAnnotationComposer get modelId {
    final $$TokenizerModelsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.modelId,
      referencedTable: $db.tokenizerModels,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TokenizerModelsTableAnnotationComposer(
            $db: $db,
            $table: $db.tokenizerModels,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TrainingSourcesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrainingSourcesTable,
          TrainingSource,
          $$TrainingSourcesTableFilterComposer,
          $$TrainingSourcesTableOrderingComposer,
          $$TrainingSourcesTableAnnotationComposer,
          $$TrainingSourcesTableCreateCompanionBuilder,
          $$TrainingSourcesTableUpdateCompanionBuilder,
          (TrainingSource, $$TrainingSourcesTableReferences),
          TrainingSource,
          PrefetchHooks Function({bool modelId})
        > {
  $$TrainingSourcesTableTableManager(
    _$AppDatabase db,
    $TrainingSourcesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrainingSourcesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrainingSourcesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrainingSourcesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> modelId = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> bytes = const Value.absent(),
                Value<int> characters = const Value.absent(),
                Value<int> lines = const Value.absent(),
                Value<String> contentHash = const Value.absent(),
              }) => TrainingSourcesCompanion(
                id: id,
                modelId: modelId,
                position: position,
                name: name,
                bytes: bytes,
                characters: characters,
                lines: lines,
                contentHash: contentHash,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String modelId,
                required int position,
                required String name,
                required int bytes,
                required int characters,
                required int lines,
                required String contentHash,
              }) => TrainingSourcesCompanion.insert(
                id: id,
                modelId: modelId,
                position: position,
                name: name,
                bytes: bytes,
                characters: characters,
                lines: lines,
                contentHash: contentHash,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TrainingSourcesTable, TrainingSource>(table),
                  $$TrainingSourcesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({modelId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                    if (modelId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.modelId,
                        referencedTable: $$TrainingSourcesTableReferences
                            ._modelIdTable(db),
                        referencedColumn: $$TrainingSourcesTableReferences
                            ._modelIdTable(db)
                            .id,
                      ) as T;
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

typedef $$TrainingSourcesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrainingSourcesTable,
      TrainingSource,
      $$TrainingSourcesTableFilterComposer,
      $$TrainingSourcesTableOrderingComposer,
      $$TrainingSourcesTableAnnotationComposer,
      $$TrainingSourcesTableCreateCompanionBuilder,
      $$TrainingSourcesTableUpdateCompanionBuilder,
      (TrainingSource, $$TrainingSourcesTableReferences),
      TrainingSource,
      PrefetchHooks Function({bool modelId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TokenizerModelsTableTableManager get tokenizerModels =>
      $$TokenizerModelsTableTableManager(_db, _db.tokenizerModels);
  $$TrainingSourcesTableTableManager get trainingSources =>
      $$TrainingSourcesTableTableManager(_db, _db.trainingSources);
}
