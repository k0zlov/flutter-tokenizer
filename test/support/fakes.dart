import 'dart:async';

import 'package:flutter_tokenizer/core/domain/tokenizer_engine.dart';
import 'package:flutter_tokenizer/core/domain/tokenizer_entities.dart';
import 'package:flutter_tokenizer/features/models/domain/model_repository.dart';
import 'package:flutter_tokenizer/features/training/domain/corpus_picker.dart';

const piece = TokenPiece(id: 65, bytes: [65], text: 'A', hex: '41');
final model = SavedModel(
  id: 'demo',
  name: 'Demo model',
  fileName: 'demo.json',
  createdAt: DateTime(2026),
  vocabularySize: 256,
  targetVocabularySize: 256,
  merges: 0,
  corpusBytes: 3,
  corpusCharacters: 3,
  trainingMilliseconds: 3,
  fileBytes: 100,
  minPairFrequency: 2,
  embeddingDimensions: 256,
  bytesPerWeight: 4,
  sources: const [
    CorpusSource(
      name: 'demo.txt',
      bytes: 3,
      characters: 3,
      lines: 1,
      sha256: 'abc',
    ),
  ],
);

class MemoryRepository implements ModelRepository {
  MemoryRepository({this.models = const []});
  List<SavedModel> models;
  final changes = StreamController<List<SavedModel>>.broadcast();
  @override
  Future<void> rename(SavedModel selected, String name) async {
    final validated = validateModelName(name);
    models = [
      for (final m in models)
        if (m.id == selected.id) m.withName(validated) else m,
    ];
    changes.add(models);
  }

  @override
  Future<void> delete(SavedModel selected) async {
    models = models.where((m) => m.id != selected.id).toList();
    changes.add(models);
  }

  @override
  String modelPath(SavedModel model) => model.fileName;
  @override
  Stream<List<SavedModel>> watchModels() async* {
    yield models;
    yield* changes.stream;
  }

  @override
  Future<SavedModel> save(
    TrainingSettings settings,
    List<CorpusSource> sources,
    TrainedArtifact artifact,
  ) async {
    models = [model];
    changes.add(models);
    return model;
  }
}

class StubPicker implements CorpusPicker {
  @override
  Future<List<CorpusDocument>> readDroppedFiles(
    List<CorpusFileReference> files,
  ) => pick();
  @override
  Future<List<CorpusDocument>> pick() async => [
    const CorpusDocument(
      CorpusSource(
        name: 'demo.txt',
        bytes: 3,
        characters: 3,
        lines: 1,
        sha256: 'abc',
      ),
      'AAA',
    ),
  ];
}

class StubEngine implements TokenizerEngine {
  StubEngine({this.builtInModels = const []});
  @override
  final List<BuiltInModel> builtInModels;
  @override
  Future<TokenizationResult> tokenizeBuiltIn(
    BuiltInModel model,
    String text,
  ) async => TokenizationResult(
    ids: const [65],
    pieces: const [],
    supportsTokenDetails: false,
    decoded: text,
    roundTrip: true,
    metrics: const {'UTF-8 bytes': 1},
    elapsedMicroseconds: 100,
  );
  @override
  Future<ModelInspection> inspect(String path) async =>
      const ModelInspection([piece], []);
  @override
  Future<TokenizationResult> tokenize(String path, String text) async =>
      TokenizationResult(
        ids: const [65],
        pieces: const [piece],
        decoded: text,
        roundTrip: true,
        metrics: const {'UTF-8 bytes': 1},
        elapsedMicroseconds: 100,
      );
  @override
  Future<TrainedArtifact> train(
    TrainingSettings settings,
    List<CorpusDocument> documents,
    void Function(TrainingProgress) onProgress,
    CancellationSignal cancellation,
  ) async {
    settings.validate();
    onProgress(const TrainingProgress(fraction: 1));
    return const TrainedArtifact(
      json: '{}',
      vocabularySize: 256,
      merges: 0,
      corpusBytes: 3,
      corpusCharacters: 3,
      trainingMilliseconds: 3,
    );
  }
}
