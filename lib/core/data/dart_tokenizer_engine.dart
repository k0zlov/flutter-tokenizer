import 'dart:convert';
import 'dart:isolate';

import 'package:dart_tokenizer/dart_tokenizer.dart';

import '../domain/tokenizer_engine.dart';
import '../domain/tokenizer_entities.dart';

class DartTokenizerEngine implements TokenizerEngine {
  const DartTokenizerEngine();

  // Derived from the installed dart_tokenizer package; no persisted/deletable rows.
  static final _builtIns = List<BuiltInModel>.unmodifiable([
    for (final model in TiktokenModel.values)
      BuiltInModel(
        name: model.modelName,
        encoding: model.encoding.encodingName,
        kind: BuiltInKind.model,
      ),
    for (final encoding in TiktokenEncoding.values)
      BuiltInModel(
        name: encoding.encodingName,
        encoding: encoding.encodingName,
        kind: BuiltInKind.encoding,
      ),
  ]);

  @override
  List<BuiltInModel> get builtInModels => _builtIns;

  @override
  Future<TokenizationResult> tokenizeBuiltIn(
    BuiltInModel model,
    String text,
  ) => Isolate.run(() {
    try {
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
      final watch = Stopwatch()..start();
      final ids = tokenizer.encode(text);
      watch.stop();
      final decoded = tokenizer.decode(ids);
      final metrics = const TokenizerEvaluator().evaluate(tokenizer, text);
      // The wrapper exposes full-sequence decoding, not lossless per-token bytes.
      // Do not decode tokens individually: a token may split a UTF-8 character.
      return TokenizationResult(
        ids: ids,
        pieces: const [],
        supportsTokenDetails: false,
        decoded: decoded,
        roundTrip: decoded == text,
        elapsedMicroseconds: watch.elapsedMicroseconds,
        metrics: {
          ..._metrics(metrics),
          'Vocabulary size': tokenizer.vocabularySize,
        },
      );
    } catch (_) {
      throw const AppFailure(
        'Could not use this built-in tokenizer. Please try again.',
      );
    }
  });

  @override
  Future<TrainedArtifact> train(
    TrainingSettings settings,
    List<CorpusDocument> documents,
    void Function(TrainingProgress) onProgress,
    CancellationSignal cancellation,
  ) async {
    settings.validate();
    if (documents.isEmpty || documents.every((d) => d.text.trim().isEmpty)) {
      throw const AppFailure('Add at least one non-empty UTF-8 text file.');
    }
    if (documents.fold<int>(0, (sum, d) => sum + d.source.bytes) >
        20 * 1024 * 1024) {
      throw const AppFailure(
        'The demo supports up to 20 MiB of corpus text per model.',
      );
    }
    if (cancellation.isCancelled) throw const TrainingCancelled();
    final port = ReceivePort();
    Isolate? worker;
    try {
      worker = await Isolate.spawn(
        _trainWorker,
        (port.sendPort, settings, documents),
        onError: port.sendPort,
        onExit: port.sendPort,
      );
      cancellation.whenCancelled.then((_) => port.sendPort.send('cancel'));
      await for (final event in port) {
        if (cancellation.isCancelled || event == 'cancel') {
          throw const TrainingCancelled();
        }
        if (event is TrainingProgress) {
          onProgress(event);
        } else if (event is TrainedArtifact) {
          return event;
        } else if (event is AppFailure) {
          throw event;
        } else if (event == null || event is List) {
          throw const AppFailure(
            'The training worker stopped unexpectedly. Try a smaller corpus.',
          );
        }
      }
      throw const AppFailure('Training did not produce a model.');
    } finally {
      worker?.kill(priority: Isolate.immediate);
      port.close();
    }
  }

  @override
  Future<TokenizationResult> tokenize(String modelPath, String text) =>
      Isolate.run(() async {
        try {
          final tokenizer = await BpeTokenizer.load(modelPath);
          final watch = Stopwatch()..start();
          final ids = tokenizer.encode(text);
          watch.stop();
          final decoded = tokenizer.decode(ids);
          final info = const BpeTokenizerTranslator().translate(tokenizer);
          final byId = {
            for (final token in info.vocabulary) token.id: _piece(token),
          };
          final metrics = const TokenizerEvaluator().evaluate(tokenizer, text);
          return TokenizationResult(
            ids: ids,
            pieces: [for (final id in ids) byId[id]!],
            decoded: decoded,
            roundTrip: decoded == text,
            elapsedMicroseconds: watch.elapsedMicroseconds,
            metrics: _metrics(metrics),
          );
        } catch (_) {
          throw const AppFailure(
            'Could not read or use this model. Its local file may be missing or damaged.',
          );
        }
      });

  @override
  Future<ModelInspection> inspect(String modelPath) => Isolate.run(() async {
    try {
      final tokenizer = await BpeTokenizer.load(modelPath);
      final info = const BpeTokenizerTranslator().translate(tokenizer);
      return ModelInspection(info.vocabulary.map(_piece).toList(), [
        for (final merge in info.merges)
          MergeEntry(
            merge.rank,
            _piece(merge.left),
            _piece(merge.right),
            _piece(merge.result),
          ),
      ]);
    } catch (_) {
      throw const AppFailure(
        'Could not inspect this model. Its local file may be missing or damaged.',
      );
    }
  });
}

TokenPiece _piece(BpeTokenInfo token) => TokenPiece(
  id: token.id,
  bytes: token.bytes,
  text: token.text,
  hex: token.hex,
);

void _trainWorker((SendPort, TrainingSettings, List<CorpusDocument>) request) {
  final (port, settings, documents) = request;
  try {
    // A newline separates files; order is preserved and recorded in the database.
    final corpus = documents.map((d) => d.text).join('\n');
    final throttle = Stopwatch()..start();
    final tokenizer = BpeTrainer(minPairFrequency: settings.minPairFrequency)
        .train(
          corpus,
          name: settings.name.trim(),
          vocabularySize: settings.vocabularySize,
          onProgress: (progress) {
            if (!progress.isCompleted &&
                progress.current != 0 &&
                throttle.elapsedMilliseconds < 50) {
              return;
            }
            throttle.reset();
            port.send(
              TrainingProgress(
                fraction: progress.progress,
                current: progress.current ?? 0,
                total: progress.total ?? 0,
                stage: progress.stage ?? 'Training',
                elapsedMilliseconds: progress.elapsed.inMilliseconds,
                vocabularySize:
                    progress.details['currentVocabularySize'] as int? ?? 256,
                remainingTokens:
                    progress.details['currentTokenCount'] as int? ?? 0,
              ),
            );
          },
        );
    final info = tokenizer.trainingInfo!;
    port.send(
      TrainedArtifact(
        json: jsonEncode(tokenizer.toJson()),
        vocabularySize: info.actualVocabularySize,
        merges: info.mergesCount,
        corpusBytes: info.corpusBytes,
        corpusCharacters: info.corpusCharacters,
        trainingMilliseconds: info.trainingDuration.inMilliseconds,
      ),
    );
  } catch (_) {
    port.send(
      const AppFailure(
        'Training failed. Check the corpus and try a smaller vocabulary.',
      ),
    );
  }
}

Map<String, num> _metrics(TokenizerMetrics metrics) => {
  'Characters': metrics.characters,
  'UTF-8 bytes': metrics.bytes,
  'Words': metrics.words,
  'Tokens / word': metrics.tokensPerWord,
  'Bytes / token': metrics.bytesPerToken,
  'Characters / token': metrics.charactersPerToken,
  'Characters / second': metrics.charactersPerSecond,
};
