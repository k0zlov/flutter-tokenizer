import 'dart:convert';
import 'dart:io';

import 'package:flutter_tokenizer/features/comparison/presentation/comparison_cubit.dart';
import 'package:flutter_tokenizer/features/tokenizer/application/tokenize_text.dart';

import 'package:dart_tokenizer/dart_tokenizer.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tokenizer/core/data/app_database.dart';
import 'package:flutter_tokenizer/core/data/dart_tokenizer_engine.dart';
import 'package:flutter_tokenizer/core/domain/tokenizer_entities.dart';
import 'package:flutter_tokenizer/features/models/data/local_model_repository.dart';
import 'package:flutter_tokenizer/features/training/application/train_model.dart';

CorpusDocument document(String name, String text) => CorpusDocument(
  CorpusSource(
    name: name,
    bytes: utf8.encode(text).length,
    characters: text.runes.length,
    lines: const LineSplitter().convert(text).length,
    sha256: 'test-fingerprint-$name',
  ),
  text,
);

void main() {
  const engine = DartTokenizerEngine();
  late Directory directory;
  late AppDatabase database;
  late LocalModelRepository repository;
  setUp(() async {
    directory = await Directory.systemTemp.createTemp(
      'flutter_tokenizer_test_',
    );
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

  test('real package trains, persists, restarts, tokenizes Unicode, and exposes merge bytes', () async {
    final documents = [
      document('english.txt', 'banana banana banana bandana'),
      document('unicode.txt', 'Привіт 👋 Привіт 👋 Привіт 👋'),
    ];
    final progress = <TrainingProgress>[];
    var saving = false;
    final saved = await TrainModel(engine, repository)(
      const TrainingSettings(name: '  Demo model  ', vocabularySize: 512),
      documents,
      CancellationSignal(),
      progress.add,
      () => saving = true,
    );
    expect(saving, isTrue);
    expect(progress, isNotEmpty);
    expect(progress.last.current, saved.merges);
    expect(saved.name, 'Demo model');
    expect(saved.vocabularySize, greaterThan(256));
    expect(saved.vocabularySize, lessThan(512));
    expect(
      saved.corpusBytes,
      utf8.encode(documents.map((d) => d.text).join('\n')).length,
    );
    expect(await File(repository.modelPath(saved)).length(), saved.fileBytes);

    // The app's output is loadable directly by the existing package.
    final loadedByPackage = await BpeTokenizer.load(
      repository.modelPath(saved),
    );
    expect(loadedByPackage.vocabulary.length, saved.vocabularySize);
    await database.close();
    database = AppDatabase(
      NativeDatabase(File('${directory.path}/metadata.sqlite')),
    );
    repository = LocalModelRepository(
      database,
      Directory('${directory.path}/models'),
    );
    final restored = (await repository.watchModels().first).single;
    expect(restored.sources.map((s) => s.name), ['english.txt', 'unicode.txt']);
    expect(restored.sources.first.sha256, 'test-fingerprint-english.txt');
    expect(restored.embeddingDimensions, 256);
    expect(restored.minPairFrequency, 2);

    const input = 'banana Привіт 👋\nUnseen: 日本語 🧬';
    final result = await engine.tokenize(repository.modelPath(restored), input);
    expect(result.roundTrip, isTrue);
    expect(result.decoded, input);
    expect(result.ids, loadedByPackage.encode(input));
    expect(result.metrics['UTF-8 bytes'], utf8.encode(input).length);
    expect(result.metrics['Characters'], input.runes.length);
    expect(result.pieces.expand((p) => p.bytes), utf8.encode(input));
    final inspection = await engine.inspect(repository.modelPath(restored));
    expect(inspection.vocabulary.length, restored.vocabularySize);
    expect(inspection.merges.length, restored.merges);
    for (final merge in inspection.merges) {
      expect(merge.result.bytes, [...merge.left.bytes, ...merge.right.bytes]);
      expect(merge.matches('${merge.result.id}'), isTrue);
    }
    final comparison = ComparisonCubit(
      TokenizeText(engine, repository),
      engine.builtInModels,
    );
    comparison.select(true, restored);
    comparison.changeInput(input);
    await comparison.compare();
    expect(comparison.state.left.result!.ids, result.ids);
    expect(comparison.state.right.result!.roundTrip, isTrue);
    expect(
      comparison.state.left.result!.decoded,
      comparison.state.right.result!.decoded,
    );
    await comparison.close();
    final empty = await engine.tokenize(repository.modelPath(restored), '');
    expect(empty.ids, isEmpty);
    expect(empty.roundTrip, isTrue);
  });

  test(
    'base vocabulary preserves invalid UTF-8 fragments and exact round trip',
    () async {
      final saved = await TrainModel(engine, repository)(
        const TrainingSettings(name: 'Bytes', vocabularySize: 256),
        [document('tiny.txt', 'a')],
        CancellationSignal(),
        (_) {},
        () {},
      );
      final inspection = await engine.inspect(repository.modelPath(saved));
      expect(inspection.merges, isEmpty);
      expect(
        inspection.vocabulary.singleWhere((t) => t.id == 208).text,
        isNull,
      );
      expect(inspection.vocabulary.singleWhere((t) => t.id == 65).text, 'A');
      final result = await engine.tokenize(repository.modelPath(saved), 'Ї👋');
      expect(result.ids, utf8.encode('Ї👋'));
      expect(result.roundTrip, isTrue);
    },
  );

  test(
    'cancellation stops live training and never persists a partial model',
    () async {
      final cancellation = CancellationSignal();
      var updates = 0;
      await expectLater(
        TrainModel(engine, repository)(
          const TrainingSettings(name: 'Cancelled', vocabularySize: 8000),
          [
            document(
              'large.txt',
              List.filled(15000, 'abc def ghi jkl').join(' '),
            ),
          ],
          cancellation,
          (_) {
            updates++;
            cancellation.cancel();
          },
          () => fail('Must not save'),
        ),
        throwsA(isA<TrainingCancelled>()),
      );
      expect(updates, greaterThan(0));
      expect(await repository.watchModels().first, isEmpty);
      expect(await repository.directory.list().toList(), isEmpty);
    },
  );

  test('empty corpus, invalid settings, and missing model yield actionable failures', () async {
    await expectLater(
      engine.train(
        const TrainingSettings(name: 'Bad', vocabularySize: 255),
        [document('a.txt', 'abc')],
        (_) {},
        CancellationSignal(),
      ),
      throwsA(isA<AppFailure>()),
    );
    await expectLater(
      engine.train(
        const TrainingSettings(name: 'Empty', vocabularySize: 256),
        [],
        (_) {},
        CancellationSignal(),
      ),
      throwsA(isA<AppFailure>()),
    );
    await expectLater(
      engine.tokenize('${directory.path}/missing.json', 'text'),
      throwsA(isA<AppFailure>()),
    );
  });

  test('failed metadata write removes its model file; startup recovers interrupted saves', () async {
    final saved = await TrainModel(engine, repository)(
      const TrainingSettings(name: 'Keep', vocabularySize: 256),
      [document('a.txt', 'abc')],
      CancellationSignal(),
      (_) {},
      () {},
    );
    final orphan = File('${repository.directory.path}/model_deadbeef.json');
    final partial = File('${repository.directory.path}/model_partial.json.tmp');
    await orphan.writeAsString('{}');
    await partial.writeAsString('{');
    await repository.recoverInterruptedSaves();
    expect(await orphan.exists(), isFalse);
    expect(await partial.exists(), isFalse);
    expect(await File(repository.modelPath(saved)).exists(), isTrue);
    // Force an actual transaction failure after the model file has been written.
    await database.customStatement(
      'CREATE TRIGGER reject_models BEFORE INSERT ON tokenizer_models BEGIN SELECT RAISE(ABORT, \'test failure\'); END',
    );
    await expectLater(
      TrainModel(engine, repository)(
        const TrainingSettings(name: 'Fail', vocabularySize: 256),
        [document('b.txt', 'abc')],
        CancellationSignal(),
        (_) {},
        () {},
      ),
      throwsA(isA<AppFailure>()),
    );
    expect((await repository.directory.list().toList()).length, 1);
    expect((await repository.watchModels().first).single.id, saved.id);
  });
}
