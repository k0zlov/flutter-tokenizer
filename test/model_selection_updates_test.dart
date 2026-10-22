import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tokenizer/core/domain/tokenizer_entities.dart';
import 'package:flutter_tokenizer/features/comparison/presentation/comparison_cubit.dart';
import 'package:flutter_tokenizer/features/tokenizer/application/tokenize_text.dart';
import 'package:flutter_tokenizer/features/tokenizer/presentation/tokenizer_cubit.dart';
import 'package:flutter_tokenizer/features/training/application/train_model.dart';
import 'package:flutter_tokenizer/features/training/presentation/training_cubit.dart';

import 'support/fakes.dart';

const builtin = BuiltInModel(
  name: 'gpt-4',
  encoding: 'cl100k_base',
  kind: BuiltInKind.model,
);
const result = TokenizationResult(
  ids: [65],
  pieces: [piece],
  decoded: 'A',
  roundTrip: true,
  metrics: {},
  elapsedMicroseconds: 1,
);

class PendingCustomEngine extends StubEngine {
  PendingCustomEngine() : super(builtInModels: const [builtin]);
  final pending = <Completer<TokenizationResult>>[];
  @override
  Future<TokenizationResult> tokenize(String path, String text) {
    final completer = Completer<TokenizationResult>();
    pending.add(completer);
    return completer.future;
  }
}

void main() {
  for (final delete in [false, true]) {
    test(
      '${delete ? "deletion" : "rename"} during tokenization cannot restore obsolete selections',
      () async {
        final repository = MemoryRepository(models: [model]);
        final engine = PendingCustomEngine();
        final tokenizer = TokenizerCubit(engine, repository);
        final comparison = ComparisonCubit(
          TokenizeText(engine, repository),
          engine.builtInModels,
        );
        addTearDown(repository.changes.close);
        addTearDown(tokenizer.close);
        addTearDown(comparison.close);
        tokenizer.select(model);
        comparison.select(true, model);
        final tokenizing = tokenizer.tokenize('A');
        final comparing = comparison.compare();
        final options = <ModelOption>[
          builtin,
          if (!delete) model.withName('New name'),
        ];
        tokenizer.refreshModels(options);
        comparison.refreshModels(options);
        for (final pending in engine.pending) {
          pending.complete(result);
        }
        await Future.wait([tokenizing, comparing]);
        expect(tokenizer.state.model!.name, delete ? builtin.name : 'New name');
        expect(
          comparison.state.left.model!.name,
          delete ? builtin.name : 'New name',
        );
        expect(tokenizer.state.result, delete ? isNull : isNotNull);
        expect(comparison.state.left.result, delete ? isNull : isNotNull);
        expect(tokenizer.state.busy, isFalse);
        expect(comparison.state.busy, isFalse);
      },
    );
  }

  test('training success link follows renaming and disappears on deletion without losing corpus', () async {
    final repository = MemoryRepository();
    final cubit = TrainingCubit(
      StubPicker(),
      TrainModel(StubEngine(), repository),
    );
    addTearDown(repository.changes.close);
    addTearDown(cubit.close);
    await cubit.addFiles();
    await cubit.start(
      const TrainingSettings(name: 'Demo', vocabularySize: 256),
    );
    cubit.refreshModels([model.withName('New name')]);
    expect(cubit.state.saved!.name, 'New name');
    cubit.refreshModels([]);
    expect(cubit.state.saved, isNull);
    expect(cubit.state.documents, hasLength(1));
    expect(cubit.state.phase, TrainingPhase.idle);
  });
}
