import '../../../core/domain/tokenizer_engine.dart';
import '../../../core/domain/tokenizer_entities.dart';
import '../../models/domain/model_repository.dart';

class TrainModel {
  const TrainModel(this.engine, this.repository);
  final TokenizerEngine engine;
  final ModelRepository repository;

  Future<SavedModel> call(
    TrainingSettings settings,
    List<CorpusDocument> documents,
    CancellationSignal cancellation,
    void Function(TrainingProgress) onProgress,
    void Function() onSaving,
  ) async {
    settings.validate();
    final artifact = await engine.train(
      settings,
      documents,
      onProgress,
      cancellation,
    );
    if (cancellation.isCancelled) throw const TrainingCancelled();
    onSaving();
    return repository.save(
      settings,
      documents.map((d) => d.source).toList(),
      artifact,
    );
  }
}
