import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tokenizer/core/data/dart_tokenizer_engine.dart';
import 'package:flutter_tokenizer/core/domain/tokenizer_entities.dart';
import 'package:flutter_tokenizer/features/comparison/presentation/comparison_cubit.dart';
import 'package:flutter_tokenizer/features/tokenizer/application/tokenize_text.dart';

import 'support/fakes.dart';

class PendingEngine extends StubEngine {
  PendingEngine()
    : super(builtInModels: const DartTokenizerEngine().builtInModels);
  final calls = <(String, String, Completer<TokenizationResult>)>[];
  @override
  Future<TokenizationResult> tokenizeBuiltIn(BuiltInModel model, String text) {
    final completer = Completer<TokenizationResult>();
    calls.add((model.id, text, completer));
    return completer.future;
  }
}

TokenizationResult result(int count) => TokenizationResult(
  ids: List.filled(count, 65),
  pieces: const [],
  supportsTokenDetails: false,
  decoded: 'test',
  roundTrip: true,
  metrics: const {},
  elapsedMicroseconds: 1,
);

void main() {
  late PendingEngine engine;
  late MemoryRepository repository;
  late ComparisonCubit cubit;
  setUp(() {
    engine = PendingEngine();
    repository = MemoryRepository();
    cubit = ComparisonCubit(
      TokenizeText(engine, repository),
      engine.builtInModels,
    );
  });
  tearDown(() async {
    await cubit.close();
    await repository.changes.close();
  });

  test('default models use different encodings, both receive identical input, errors are independent', () async {
    expect(
      (cubit.state.left.model as BuiltInModel).encoding,
      isNot((cubit.state.right.model as BuiltInModel).encoding),
    );
    cubit.changeInput('same text 👋');
    final done = cubit.compare();
    expect(engine.calls.map((c) => c.$2), ['same text 👋', 'same text 👋']);
    expect(cubit.state.left.busy && cubit.state.right.busy, isTrue);
    engine.calls[1].$3.complete(result(2));
    await Future<void>.delayed(Duration.zero);
    expect(cubit.state.left.busy, isTrue);
    expect(cubit.state.right.result!.ids.length, 2);
    engine.calls[0].$3.completeError(const AppFailure('Missing custom model'));
    await done;
    expect(cubit.state.left.error, 'Missing custom model');
    expect(cubit.state.right.result!.ids.length, 2);
    expect(cubit.state.busy, isFalse);
  });

  test('editing shared input and changing a selection discard stale in-flight results', () async {
    final old = cubit.compare();
    cubit.changeInput('new text');
    engine.calls[0].$3.complete(result(8));
    engine.calls[1].$3.complete(result(9));
    await old;
    expect(cubit.state.input, 'new text');
    expect(cubit.state.left.result, isNull);
    expect(cubit.state.right.result, isNull);
    final next = cubit.compare();
    cubit.select(false, engine.builtInModels.last);
    engine.calls[2].$3.complete(result(3));
    engine.calls[3].$3.complete(result(4));
    await next;
    expect(cubit.state.left.result, isNull);
    expect(cubit.state.right.result, isNull);
    expect(cubit.state.right.model!.id, engine.builtInModels.last.id);
  });

  test(
    'swapping preserves the association between models and completed results',
    () async {
      final done = cubit.compare();
      final leftId = cubit.state.left.model!.id;
      engine.calls[0].$3.complete(result(3));
      engine.calls[1].$3.complete(result(5));
      await done;
      cubit.swap();
      expect(cubit.state.right.model!.id, leftId);
      expect(cubit.state.right.result!.ids.length, 3);
      expect(cubit.state.left.result!.ids.length, 5);
    },
  );

  test('input limit is enforced before either worker starts', () async {
    cubit.changeInput('a' * 100001);
    await cubit.compare();
    expect(cubit.state.error, contains('100,000'));
    expect(engine.calls, isEmpty);
  });
}
