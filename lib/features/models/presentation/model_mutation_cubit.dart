import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../domain/model_repository.dart';

class ModelMutationState {
  const ModelMutationState({
    this.busy = false,
    this.completed = false,
    this.error,
  });
  final bool busy, completed;
  final String? error;
}

class ModelMutationCubit extends Cubit<ModelMutationState> {
  ModelMutationCubit(this.repository) : super(const ModelMutationState());
  final ModelRepository repository;
  Future<void> rename(SavedModel model, String name) =>
      _run(() => repository.rename(model, name));
  Future<void> delete(SavedModel model) => _run(() => repository.delete(model));
  Future<void> _run(Future<void> Function() action) async {
    if (state.busy || state.completed) return;
    emit(const ModelMutationState(busy: true));
    try {
      await action();
      if (!isClosed) emit(const ModelMutationState(completed: true));
    } catch (error) {
      if (!isClosed) {
        emit(
          ModelMutationState(
            error: error is AppFailure
                ? error.message
                : 'Could not update the model. Please try again.',
          ),
        );
      }
    }
  }
}
