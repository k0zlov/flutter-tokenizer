import 'package:drift/drift.dart';

part 'app_database.g.dart';

class TokenizerModels extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get fileName => text()();
  DateTimeColumn get createdAt => dateTime()();
  IntColumn get vocabularySize => integer()();
  IntColumn get targetVocabularySize => integer()();
  IntColumn get merges => integer()();
  IntColumn get corpusBytes => integer()();
  IntColumn get corpusCharacters => integer()();
  IntColumn get trainingMilliseconds => integer()();
  IntColumn get fileBytes => integer()();
  IntColumn get minPairFrequency => integer()();
  IntColumn get embeddingDimensions => integer()();
  IntColumn get bytesPerWeight => integer()();
  @override
  Set<Column> get primaryKey => {id};
}

class TrainingSources extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get modelId => text().references(TokenizerModels, #id)();
  IntColumn get position => integer()();
  TextColumn get name => text()();
  IntColumn get bytes => integer()();
  IntColumn get characters => integer()();
  IntColumn get lines => integer()();
  TextColumn get contentHash => text()();
}

@DriftDatabase(tables: [TokenizerModels, TrainingSources])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);
  @override
  int get schemaVersion => 1;
  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (_) async => customStatement('PRAGMA foreign_keys = ON'),
  );
}
