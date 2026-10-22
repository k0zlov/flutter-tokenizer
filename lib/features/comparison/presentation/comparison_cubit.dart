import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../../tokenizer/application/tokenize_text.dart';

class ComparisonSlot {
  const ComparisonSlot({
    this.model,
    this.result,
    this.error,
    this.busy = false,
  });
  final ModelOption? model;
  final TokenizationResult? result;
  final String? error;
  final bool busy;
}

class ComparisonState {
  const ComparisonState({
    this.left = const ComparisonSlot(),
    this.right = const ComparisonSlot(),
    this.input = '',
    this.error,
  });
  final ComparisonSlot left, right;
  final String input;
  final String? error;
  bool get busy => left.busy || right.busy;
  bool get canCompare => left.model != null && right.model != null && !busy;
}

class ComparisonCubit extends Cubit<ComparisonState> {
  ComparisonCubit(this.tokenizeText, List<BuiltInModel> builtIns)
    : super(
        ComparisonState(
          left: ComparisonSlot(model: builtIns.firstOrNull),
          right: ComparisonSlot(
            model:
                builtIns
                    .where((m) => m.encoding != builtIns.first.encoding)
                    .firstOrNull ??
                builtIns.lastOrNull,
          ),
        ),
      );
  final TokenizeText tokenizeText;
  int _request = 0;

  void refreshModels(List<ModelOption> models) {
    ModelOption? resolve(ComparisonSlot slot) =>
        models.where((m) => m.id == slot.model?.id).firstOrNull;
    final left = resolve(state.left);
    final right = resolve(state.right);
    final removed =
        (state.left.model != null && left == null) ||
        (state.right.model != null && right == null);
    if (removed) _request++;
    ComparisonSlot refresh(ComparisonSlot slot, ModelOption? updated) =>
        slot.model != null && updated == null
        ? ComparisonSlot(model: models.firstOrNull)
        : ComparisonSlot(
            model: updated,
            result: slot.result,
            error: slot.error,
            busy: removed ? false : slot.busy,
          );
    emit(
      ComparisonState(
        input: state.input,
        error: state.error,
        left: refresh(state.left, left),
        right: refresh(state.right, right),
      ),
    );
  }

  void changeInput(String text) {
    _request++;
    emit(
      ComparisonState(
        input: text,
        left: ComparisonSlot(model: state.left.model),
        right: ComparisonSlot(model: state.right.model),
      ),
    );
  }

  void select(bool left, ModelOption model) {
    _request++;
    emit(
      ComparisonState(
        input: state.input,
        left: ComparisonSlot(model: left ? model : state.left.model),
        right: ComparisonSlot(model: left ? state.right.model : model),
      ),
    );
  }

  void swap() {
    _request++;
    emit(
      ComparisonState(
        input: state.input,
        left: ComparisonSlot(
          model: state.right.model,
          result: state.right.result,
          error: state.right.error,
        ),
        right: ComparisonSlot(
          model: state.left.model,
          result: state.left.result,
          error: state.left.error,
        ),
      ),
    );
  }

  Future<void> compare() async {
    if (!state.canCompare) return;
    if (state.input.length > 100000) {
      emit(
        ComparisonState(
          input: state.input,
          left: state.left,
          right: state.right,
          error: 'Use up to 100,000 characters for comparison.',
        ),
      );
      return;
    }
    final request = ++_request;
    final left = state.left.model!;
    final right = state.right.model!;
    final input = state.input;
    emit(
      ComparisonState(
        input: input,
        left: ComparisonSlot(model: left, busy: true),
        right: ComparisonSlot(model: right, busy: true),
      ),
    );
    await Future.wait([
      _run(request, true, left, input),
      _run(request, false, right, input),
    ]);
  }

  Future<void> _run(
    int request,
    bool left,
    ModelOption model,
    String input,
  ) async {
    ComparisonSlot result;
    try {
      result = ComparisonSlot(
        model: model,
        result: await tokenizeText(model, input),
      );
    } catch (error) {
      result = ComparisonSlot(
        model: model,
        error: error is AppFailure
            ? error.message
            : 'Could not tokenize with this model. Try again.',
      );
    }
    if (isClosed || request != _request) return;
    result = ComparisonSlot(
      model: left ? state.left.model : state.right.model,
      result: result.result,
      error: result.error,
    );
    emit(
      ComparisonState(
        input: input,
        left: left ? result : state.left,
        right: left ? state.right : result,
      ),
    );
  }
}
