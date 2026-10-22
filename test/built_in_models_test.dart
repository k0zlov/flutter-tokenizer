import 'dart:async';
import 'dart:convert';

import 'package:dart_tokenizer/dart_tokenizer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tokenizer/core/data/dart_tokenizer_engine.dart';
import 'package:flutter_tokenizer/core/domain/tokenizer_entities.dart';
import 'package:flutter_tokenizer/features/models/domain/model_repository.dart';
import 'package:flutter_tokenizer/features/models/presentation/models_cubit.dart';
import 'package:flutter_tokenizer/features/tokenizer/presentation/tokenizer_cubit.dart';

// Built-ins must not rely on persistence or a local tokenizer file.
class UnavailableRepository implements ModelRepository {
  final changes = StreamController<List<SavedModel>>.broadcast();
  @override
  Stream<List<SavedModel>> watchModels() => changes.stream;
  @override
  Future<void> rename(SavedModel model, String name) =>
      throw StateError('No storage available');
  @override
  Future<void> delete(SavedModel model) =>
      throw StateError('No storage available');
  @override
  String modelPath(SavedModel model) =>
      throw StateError('No model file available');
  @override
  Future<SavedModel> save(
    TrainingSettings settings,
    List<CorpusSource> sources,
    TrainedArtifact artifact,
  ) => throw StateError('No storage available');
}

void main() {
  const engine = DartTokenizerEngine();
  test(
    'catalog includes every package model and encoding with stable unique IDs',
    () {
      expect(
        engine.builtInModels
            .where((m) => m.kind == BuiltInKind.model)
            .map((m) => m.name),
        TiktokenModel.values.map((m) => m.modelName),
      );
      expect(
        engine.builtInModels
            .where((m) => m.kind == BuiltInKind.encoding)
            .map((m) => m.name),
        TiktokenEncoding.values.map((m) => m.encodingName),
      );
      expect(
        engine.builtInModels.map((m) => m.id).toSet().length,
        engine.builtInModels.length,
      );
      expect(() => engine.builtInModels.clear(), throwsUnsupportedError);
    },
  );

  for (final model in engine.builtInModels) {
    test(
      '${model.id} delegates to the package and preserves Unicode',
      () async {
        const text = 'Hello, Привіт 👋 日本語! <|endoftext|>\n';
        final tokenizer = switch (model.kind) {
          BuiltInKind.model => TiktokenTokenizer.fromModel(
            TiktokenModel.values.firstWhere((m) => m.modelName == model.name),
          ),
          BuiltInKind.encoding => TiktokenTokenizer.fromEncoding(
            TiktokenEncoding.values.firstWhere(
              (e) => e.encodingName == model.name,
            ),
          ),
        };
        final result = await engine.tokenizeBuiltIn(model, text);
        expect(result.ids, tokenizer.encode(text));
        expect(result.decoded, text);
        expect(result.roundTrip, isTrue);
        expect(result.metrics['Vocabulary size'], tokenizer.vocabularySize);
        expect(result.metrics['UTF-8 bytes'], utf8.encode(text).length);
        expect(result.supportsTokenDetails, isFalse);
        expect(result.pieces, isEmpty);
      },
    );
  }

  test(
    'built-ins remain available while custom library loads, fails, and retries',
    () async {
      final repository = UnavailableRepository();
      final cubit = ModelsCubit(repository, engine.builtInModels);
      addTearDown(repository.changes.close);
      addTearDown(cubit.close);
      expect(cubit.state.loading, isTrue);
      expect(cubit.state.options, engine.builtInModels);
      var updated = cubit.stream.first;
      repository.changes.addError(StateError('Storage unavailable'));
      await updated;
      expect(cubit.state.error, isNotNull);
      expect(cubit.state.options, engine.builtInModels);
      cubit.load();
      expect(cubit.state.options, engine.builtInModels);
      updated = cubit.stream.first;
      repository.changes.add([]);
      await updated;
      expect(cubit.state.error, isNull);
      expect(cubit.state.options, engine.builtInModels);
    },
  );

  test('built-in selection tokenizes empty input without a saved model or database', () async {
    final repository = UnavailableRepository();
    final cubit = TokenizerCubit(engine, repository);
    addTearDown(repository.changes.close);
    addTearDown(cubit.close);
    expect(cubit.state.model, isA<BuiltInModel>());
    await cubit.tokenize('');
    expect(cubit.state.error, isNull);
    expect(cubit.state.result!.ids, isEmpty);
    expect(cubit.state.result!.roundTrip, isTrue);
    cubit.select(engine.builtInModels.last);
    expect(cubit.state.result, isNull);
    await cubit.tokenize('Hello 👋');
    expect(cubit.state.result!.roundTrip, isTrue);
  });
}
