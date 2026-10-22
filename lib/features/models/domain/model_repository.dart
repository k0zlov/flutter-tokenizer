import '../../../core/domain/tokenizer_entities.dart';

abstract interface class ModelRepository {
  Stream<List<SavedModel>> watchModels();
  Future<SavedModel> save(
    TrainingSettings settings,
    List<CorpusSource> sources,
    TrainedArtifact artifact,
  );
  Future<void> rename(SavedModel model, String name);
  Future<void> delete(SavedModel model);
  String modelPath(SavedModel model);
}
