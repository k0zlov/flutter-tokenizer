import 'tokenizer_entities.dart';

abstract interface class TokenizerEngine {
  List<BuiltInModel> get builtInModels;
  Future<TokenizationResult> tokenizeBuiltIn(BuiltInModel model, String text);
  Future<TrainedArtifact> train(
    TrainingSettings settings,
    List<CorpusDocument> documents,
    void Function(TrainingProgress) onProgress,
    CancellationSignal cancellation,
  );
  Future<TokenizationResult> tokenize(String modelPath, String text);
  Future<ModelInspection> inspect(String modelPath);
}
