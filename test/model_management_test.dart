import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tokenizer/core/data/app_database.dart';
import 'package:flutter_tokenizer/core/domain/tokenizer_entities.dart';
import 'package:flutter_tokenizer/features/models/data/local_model_repository.dart';

void main() {
  late Directory directory;
  late AppDatabase database;
  late LocalModelRepository repository;
  const source = CorpusSource(
    name: 'source.txt',
    bytes: 3,
    characters: 3,
    lines: 1,
    sha256: 'abc',
  );
  const artifact = TrainedArtifact(
    json: '{"name":"Original"}',
    vocabularySize: 256,
    merges: 0,
    corpusBytes: 3,
    corpusCharacters: 3,
    trainingMilliseconds: 1,
  );
  Future<SavedModel> save() => repository.save(
    const TrainingSettings(name: 'Original', vocabularySize: 256),
    [source],
    artifact,
  );
  setUp(() async {
    directory = await Directory.systemTemp.createTemp('model_management_');
    database = AppDatabase(
      NativeDatabase(File('${directory.path}/metadata.sqlite')),
    );
    repository = LocalModelRepository(
      database,
      Directory('${directory.path}/models'),
    );
    await repository.recoverInterruptedSaves();
  });
  tearDown(() async {
    await database.close();
    await directory.delete(recursive: true);
  });

  test(
    'rename persists after restart and preserves tokenizer bytes and metadata',
    () async {
      final saved = await save();
      final before = await File(repository.modelPath(saved)).readAsBytes();
      final createdAt = (await repository.watchModels().first).single.createdAt;
      await repository.rename(saved, '  Українська 8k  ');
      await database.close();
      database = AppDatabase(
        NativeDatabase(File('${directory.path}/metadata.sqlite')),
      );
      repository = LocalModelRepository(
        database,
        Directory('${directory.path}/models'),
      );
      final renamed = (await repository.watchModels().first).single;
      expect(renamed.name, 'Українська 8k');
      expect(renamed.id, saved.id);
      expect(renamed.createdAt, createdAt);
      expect(renamed.sources.single.name, source.name);
      expect(await File(repository.modelPath(renamed)).readAsBytes(), before);
      for (final invalid in ['   ', 'x' * 81]) {
        await expectLater(
          repository.rename(renamed, invalid),
          throwsA(isA<AppFailure>()),
        );
      }
      expect((await repository.watchModels().first).single.name, renamed.name);
    },
  );

  test(
    'delete removes only selected model, source records and model file',
    () async {
      final saved = await save();
      final other = await save();
      final originalText = File('${directory.path}/source.txt');
      await originalText.writeAsString('abc');
      await repository.delete(saved);
      await repository.delete(saved); // Idempotent stale action.
      expect(await File(repository.modelPath(saved)).exists(), isFalse);
      expect(
        await File('${repository.modelPath(saved)}.deleting').exists(),
        isFalse,
      );
      expect(await File(repository.modelPath(other)).exists(), isTrue);
      expect((await repository.watchModels().first).single.id, other.id);
      expect(
        (await database.select(database.trainingSources).get()).single.modelId,
        other.id,
      );
      expect(await originalText.readAsString(), 'abc');
      await expectLater(
        repository.rename(saved, 'Missing'),
        throwsA(isA<AppFailure>()),
      );
    },
  );

  test(
    'metadata failure rolls back source removal and restores staged file',
    () async {
      final saved = await save();
      await database.customStatement(
        "CREATE TRIGGER reject_delete BEFORE DELETE ON tokenizer_models BEGIN SELECT RAISE(ABORT, 'test failure'); END",
      );
      await expectLater(repository.delete(saved), throwsA(isA<AppFailure>()));
      expect(
        (await repository.watchModels().first).single.sources,
        hasLength(1),
      );
      expect(
        await File(repository.modelPath(saved)).readAsString(),
        artifact.json,
      );
      expect(
        await File('${repository.modelPath(saved)}.deleting').exists(),
        isFalse,
      );
    },
  );

  test(
    'startup restores uncommitted deletions and cleans committed deletions',
    () async {
      final saved = await save();
      final original = File(repository.modelPath(saved));
      await original.rename('${original.path}.deleting');
      await repository.recoverInterruptedSaves();
      expect(await original.exists(), isTrue);
      await original.rename('${original.path}.deleting');
      await database.customStatement('DELETE FROM training_sources');
      await database.customStatement('DELETE FROM tokenizer_models');
      await repository.recoverInterruptedSaves();
      expect(await repository.directory.list().toList(), isEmpty);
    },
  );

  test('missing model file can still be removed from the library', () async {
    final saved = await save();
    await File(repository.modelPath(saved)).delete();
    await repository.delete(saved);
    expect(await repository.watchModels().first, isEmpty);
    expect(await database.select(database.trainingSources).get(), isEmpty);
  });
}
