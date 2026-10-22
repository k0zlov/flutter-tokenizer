import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:path/path.dart' as p;

import '../../../core/data/app_database.dart';
import '../../../core/domain/tokenizer_entities.dart';
import '../domain/model_repository.dart';

class LocalModelRepository implements ModelRepository {
  LocalModelRepository(this.database, this.directory);
  final AppDatabase database;
  final Directory directory;

  @override
  String modelPath(SavedModel model) => p.join(directory.path, model.fileName);

  @override
  Stream<List<SavedModel>> watchModels() {
    final models = database.tokenizerModels;
    final sources = database.trainingSources;
    final query =
        database.select(models).join([
          leftOuterJoin(sources, sources.modelId.equalsExp(models.id)),
        ])..orderBy([
          OrderingTerm.desc(models.createdAt),
          OrderingTerm.asc(sources.position),
        ]);
    return query.watch().map((rows) {
      final records = <String, TokenizerModel>{};
      final corpus = <String, List<CorpusSource>>{};
      for (final row in rows) {
        final model = row.readTable(models);
        records[model.id] = model;
        final source = row.readTableOrNull(sources);
        if (source != null) {
          (corpus[model.id] ??= []).add(
            CorpusSource(
              name: source.name,
              bytes: source.bytes,
              characters: source.characters,
              lines: source.lines,
              sha256: source.contentHash,
            ),
          );
        }
      }
      return records.values
          .map(
            (m) => SavedModel(
              id: m.id,
              name: m.name,
              fileName: m.fileName,
              createdAt: m.createdAt,
              vocabularySize: m.vocabularySize,
              targetVocabularySize: m.targetVocabularySize,
              merges: m.merges,
              corpusBytes: m.corpusBytes,
              corpusCharacters: m.corpusCharacters,
              trainingMilliseconds: m.trainingMilliseconds,
              fileBytes: m.fileBytes,
              minPairFrequency: m.minPairFrequency,
              embeddingDimensions: m.embeddingDimensions,
              bytesPerWeight: m.bytesPerWeight,
              sources: List.unmodifiable(corpus[m.id] ?? []),
            ),
          )
          .toList();
    });
  }

  @override
  Future<void> rename(SavedModel model, String name) async {
    final validated = validateModelName(name);
    try {
      final changed =
          await (database.update(database.tokenizerModels)
                ..where((row) => row.id.equals(model.id)))
              .write(TokenizerModelsCompanion(name: Value(validated)));
      if (changed == 0) {
        throw const AppFailure('This model is no longer in your library.');
      }
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure('Could not rename the model. Please try again.');
    }
  }

  @override
  Future<void> delete(SavedModel model) async {
    File? original;
    File? staged;
    try {
      await database.transaction(() async {
        final record = await (database.select(
          database.tokenizerModels,
        )..where((row) => row.id.equals(model.id))).getSingleOrNull();
        if (record == null) return;
        // Only the persisted app-owned filename may be removed.
        if (!RegExp(r'^model_[a-f0-9]+\.json$').hasMatch(record.fileName)) {
          throw const AppFailure(
            'The model file location is invalid. Nothing was deleted.',
          );
        }
        original = File(p.join(directory.path, record.fileName));
        if (await original!.exists()) {
          final target = File('${original!.path}.deleting');
          if (await target.exists()) {
            throw const AppFailure(
              'A previous deletion needs recovery. Restart the app and try again.',
            );
          }
          staged = await original!.rename(target.path);
        }
        await (database.delete(
          database.trainingSources,
        )..where((row) => row.modelId.equals(model.id))).go();
        await (database.delete(
          database.tokenizerModels,
        )..where((row) => row.id.equals(model.id))).go();
      });
    } catch (error) {
      if (staged != null) {
        try {
          await staged!.rename(original!.path);
        } catch (_) {
          throw const AppFailure(
            'Deletion failed. Restart the app to restore the model file.',
          );
        }
      }
      if (error is AppFailure) rethrow;
      throw const AppFailure('Could not delete the model. Please try again.');
    }
    if (staged != null) {
      try {
        await staged!.delete();
      } catch (_) {
        throw const AppFailure(
          'The model was removed from the library. Restart the app to finish cleaning up its file.',
        );
      }
    }
  }

  /// Recover interrupted saves and deletions inside the app's model directory.
  Future<void> recoverInterruptedSaves() async {
    await directory.create(recursive: true);
    final records = await database.select(database.tokenizerModels).get();
    final referenced = records.map((r) => r.fileName).toSet();
    await for (final entry in directory.list()) {
      final name = p.basename(entry.path);
      if (entry is File &&
          RegExp(r'^model_[a-f0-9]+\.json\.deleting$').hasMatch(name)) {
        final originalName = name.substring(
          0,
          name.length - '.deleting'.length,
        );
        final original = File(p.join(directory.path, originalName));
        if (referenced.contains(originalName) && !await original.exists()) {
          await entry.rename(original.path);
        } else {
          await entry.delete();
        }
        continue;
      }
      if (entry is File &&
          (name.endsWith('.tmp') ||
              (RegExp(r'^model_[a-f0-9]+\.json$').hasMatch(name) &&
                  !referenced.contains(name)))) {
        await entry.delete();
      }
    }
  }

  @override
  Future<SavedModel> save(
    TrainingSettings settings,
    List<CorpusSource> sources,
    TrainedArtifact artifact,
  ) async {
    settings.validate();
    await directory.create(recursive: true);
    final random = Random.secure();
    final id = List.generate(
      16,
      (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
    ).join();
    final fileName = 'model_$id.json';
    final file = File(p.join(directory.path, fileName));
    final temporary = File('${file.path}.tmp');
    final created = DateTime.now();
    final bytes = utf8.encode(artifact.json);
    try {
      await temporary.writeAsBytes(bytes, flush: true);
      await temporary.rename(file.path);
      await database.transaction(() async {
        await database
            .into(database.tokenizerModels)
            .insert(
              TokenizerModelsCompanion.insert(
                id: id,
                name: settings.name.trim(),
                fileName: fileName,
                createdAt: created,
                vocabularySize: artifact.vocabularySize,
                targetVocabularySize: settings.vocabularySize,
                merges: artifact.merges,
                corpusBytes: artifact.corpusBytes,
                corpusCharacters: artifact.corpusCharacters,
                trainingMilliseconds: artifact.trainingMilliseconds,
                fileBytes: bytes.length,
                minPairFrequency: settings.minPairFrequency,
                embeddingDimensions: settings.embeddingDimensions,
                bytesPerWeight: settings.bytesPerWeight,
              ),
            );
        for (var i = 0; i < sources.length; i++) {
          final source = sources[i];
          await database
              .into(database.trainingSources)
              .insert(
                TrainingSourcesCompanion.insert(
                  modelId: id,
                  position: i,
                  name: source.name,
                  bytes: source.bytes,
                  characters: source.characters,
                  lines: source.lines,
                  contentHash: source.sha256,
                ),
              );
        }
      });
    } catch (_) {
      for (final candidate in [temporary, file]) {
        if (await candidate.exists()) await candidate.delete();
      }
      throw const AppFailure(
        'Could not save the model. Check available disk space and try again.',
      );
    }
    return SavedModel(
      id: id,
      name: settings.name.trim(),
      fileName: fileName,
      createdAt: created,
      vocabularySize: artifact.vocabularySize,
      targetVocabularySize: settings.vocabularySize,
      merges: artifact.merges,
      corpusBytes: artifact.corpusBytes,
      corpusCharacters: artifact.corpusCharacters,
      trainingMilliseconds: artifact.trainingMilliseconds,
      fileBytes: bytes.length,
      minPairFrequency: settings.minPairFrequency,
      embeddingDimensions: settings.embeddingDimensions,
      bytesPerWeight: settings.bytesPerWeight,
      sources: List.unmodifiable(sources),
    );
  }
}
