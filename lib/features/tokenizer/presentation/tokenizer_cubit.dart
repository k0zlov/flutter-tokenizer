import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../../../core/domain/tokenizer_engine.dart';
import '../../models/domain/model_repository.dart';
import '../application/tokenize_text.dart';

class TokenizerState {
  const TokenizerState({
    this.model,
    this.result,
    this.busy = false,
    this.error,
  });
  final ModelOption? model;
  final TokenizationResult? result;
  final bool busy;
  final String? error;
}

class TokenizerCubit extends Cubit<TokenizerState> {
  TokenizerCubit(this.engine, this.repository)
    : super(TokenizerState(model: engine.builtInModels.firstOrNull));
  final TokenizerEngine engine;
  final ModelRepository repository;
  int _request = 0;
  void select(ModelOption model) {
    _request++;
    emit(TokenizerState(model: model));
  }

  void refreshModels(List<ModelOption> models) {
    final selected = state.model;
    if (selected == null) return;
    final updated = models.where((m) => m.id == selected.id).firstOrNull;
    if (updated == null) {
      _request++;
      emit(TokenizerState(model: models.firstOrNull));
    } else if (!identical(updated, selected)) {
      emit(
        TokenizerState(
          model: updated,
          result: state.result,
          busy: state.busy,
          error: state.error,
        ),
      );
    }
  }

  void textChanged() {
    _request++;
    emit(TokenizerState(model: state.model));
  }

  Future<void> tokenize(String text) async {
    final model = state.model;
    if (model == null) return;
    if (text.length > 100000) {
      emit(
        TokenizerState(
          model: model,
          error: 'Use up to 100,000 characters per tokenization.',
        ),
      );
      return;
    }
    final request = ++_request;
    emit(TokenizerState(model: model, busy: true));
    try {
      final result = await TokenizeText(engine, repository)(model, text);
      if (!isClosed && request == _request) {
        emit(TokenizerState(model: state.model, result: result));
      }
    } catch (error) {
      if (!isClosed && request == _request) {
        emit(
          TokenizerState(
            model: state.model,
            error: error is AppFailure
                ? error.message
                : 'Tokenization failed. Please try again.',
          ),
        );
      }
    }
  }
}
