import '../../../core/domain/tokenizer_engine.dart';
import '../../../core/domain/tokenizer_entities.dart';
import '../../models/domain/model_repository.dart';

class TokenizeText {
  const TokenizeText(this.engine, this.repository);
  final TokenizerEngine engine;
  final ModelRepository repository;

  Future<TokenizationResult> call(ModelOption model, String text) {
    if (text.length > 100000) {
      throw const AppFailure('Use up to 100,000 characters per tokenization.');
    }
    return switch (model) {
      BuiltInModel() => engine.tokenizeBuiltIn(model, text),
      SavedModel() => engine.tokenize(repository.modelPath(model), text),
    };
  }
}
