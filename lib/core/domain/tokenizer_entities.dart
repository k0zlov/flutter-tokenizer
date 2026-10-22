import 'dart:async';
import 'dart:convert';

class CorpusSource {
  const CorpusSource({
    required this.name,
    required this.bytes,
    required this.characters,
    required this.lines,
    required this.sha256,
  });
  final String name;
  final int bytes;
  final int characters;
  final int lines;
  final String sha256;
  Map<String, Object> toJson() => {
    'name': name,
    'bytes': bytes,
    'characters': characters,
    'lines': lines,
    'sha256': sha256,
  };
  factory CorpusSource.fromJson(Map<String, dynamic> json) => CorpusSource(
    name: json['name'] as String,
    bytes: json['bytes'] as int,
    characters: json['characters'] as int,
    lines: json['lines'] as int,
    sha256: json['sha256'] as String,
  );
}

class CorpusDocument {
  const CorpusDocument(this.source, this.text);
  final CorpusSource source;
  final String text;
}

String validateModelName(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty || trimmed.length > 80) {
    throw const AppFailure('Enter a model name between 1 and 80 characters.');
  }
  return trimmed;
}

class TrainingSettings {
  const TrainingSettings({
    required this.name,
    required this.vocabularySize,
    this.minPairFrequency = 2,
    this.embeddingDimensions = 256,
    this.bytesPerWeight = 4,
  });
  final String name;
  final int vocabularySize;
  final int minPairFrequency;
  final int embeddingDimensions;
  final int bytesPerWeight;
  int get estimatedEmbeddingBytes =>
      vocabularySize * embeddingDimensions * bytesPerWeight;
  void validate() {
    validateModelName(name);
    if (vocabularySize < 256 || vocabularySize > 32768) {
      throw const AppFailure('Vocabulary size must be between 256 and 32,768.');
    }
    if (minPairFrequency < 1 || minPairFrequency > 1000000) {
      throw const AppFailure(
        'Minimum pair frequency must be between 1 and 1,000,000.',
      );
    }
    if (embeddingDimensions < 1 ||
        embeddingDimensions > 16384 ||
        ![2, 4].contains(bytesPerWeight)) {
      throw const AppFailure('Choose valid embedding estimate settings.');
    }
  }
}

sealed class ModelOption {
  const ModelOption();
  String get id;
  String get name;
  String get selectionLabel;
}

enum BuiltInKind { model, encoding }

final class BuiltInModel extends ModelOption {
  const BuiltInModel({
    required this.name,
    required this.encoding,
    required this.kind,
  });
  @override
  final String name;
  final String encoding;
  final BuiltInKind kind;
  @override
  String get id => 'tiktoken:${kind.name}:$name';
  @override
  String get selectionLabel => '$name · Built-in tiktoken';
}

final class SavedModel extends ModelOption {
  const SavedModel({
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
    required this.sources,
  });
  @override
  final String id;
  @override
  final String name;
  final String fileName;
  @override
  String get selectionLabel => '$name · $vocabularySize tokens';
  final DateTime createdAt;
  final int vocabularySize,
      targetVocabularySize,
      merges,
      corpusBytes,
      corpusCharacters;
  final int trainingMilliseconds,
      fileBytes,
      minPairFrequency,
      embeddingDimensions,
      bytesPerWeight;
  final List<CorpusSource> sources;
  int get estimatedEmbeddingBytes =>
      vocabularySize * embeddingDimensions * bytesPerWeight;
  SavedModel withName(String name) => SavedModel(
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
    sources: sources,
  );
}

class TokenPiece {
  const TokenPiece({
    required this.id,
    required this.bytes,
    required this.text,
    required this.hex,
  });
  final int id;
  final List<int> bytes;
  final String? text;
  final String hex;
  bool get isValidUtf8 => text != null;
  String get display => text == null ? 'Partial UTF-8' : jsonEncode(text);
  bool matches(String query) =>
      '$id ${text ?? ''} $display ${bytes.join(' ')} $hex'
          .toLowerCase()
          .contains(query.toLowerCase().trim());
}

class MergeEntry {
  const MergeEntry(this.rank, this.left, this.right, this.result);
  final int rank;
  final TokenPiece left, right, result;
  bool matches(String query) =>
      '$rank'.contains(query.trim()) ||
      left.matches(query) ||
      right.matches(query) ||
      result.matches(query);
}

class ModelInspection {
  const ModelInspection(this.vocabulary, this.merges);
  final List<TokenPiece> vocabulary;
  final List<MergeEntry> merges;
}

class TokenizationResult {
  const TokenizationResult({
    required this.ids,
    required this.pieces,
    required this.decoded,
    required this.roundTrip,
    required this.metrics,
    required this.elapsedMicroseconds,
    this.supportsTokenDetails = true,
  });
  final List<int> ids;
  final List<TokenPiece> pieces;
  final bool supportsTokenDetails;
  final String decoded;
  final bool roundTrip;
  final Map<String, num> metrics;
  final int elapsedMicroseconds;
}

class TrainingProgress {
  const TrainingProgress({
    this.fraction = 0,
    this.current = 0,
    this.total = 0,
    this.vocabularySize = 256,
    this.remainingTokens = 0,
    this.elapsedMilliseconds = 0,
    this.stage = 'Preparing corpus',
  });
  final double fraction;
  final int current,
      total,
      vocabularySize,
      remainingTokens,
      elapsedMilliseconds;
  final String stage;
}

class TrainedArtifact {
  const TrainedArtifact({
    required this.json,
    required this.vocabularySize,
    required this.merges,
    required this.corpusBytes,
    required this.corpusCharacters,
    required this.trainingMilliseconds,
  });
  final String json;
  final int vocabularySize,
      merges,
      corpusBytes,
      corpusCharacters,
      trainingMilliseconds;
}

class CancellationSignal {
  final _completer = Completer<void>();
  bool get isCancelled => _completer.isCompleted;
  Future<void> get whenCancelled => _completer.future;
  void cancel() {
    if (!isCancelled) _completer.complete();
  }
}

class TrainingCancelled implements Exception {
  const TrainingCancelled();
}

class AppFailure implements Exception {
  const AppFailure(this.message);
  final String message;
  @override
  String toString() => message;
}
