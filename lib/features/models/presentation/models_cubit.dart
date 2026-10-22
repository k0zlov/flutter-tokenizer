import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../../../core/domain/tokenizer_engine.dart';
import '../domain/model_repository.dart';

class ModelsState {
  const ModelsState({
    this.models = const [],
    this.builtIns = const [],
    this.loading = false,
    this.error,
  });
  final List<SavedModel> models;
  final List<BuiltInModel> builtIns;
  List<ModelOption> get options => [...builtIns, ...models];
  final bool loading;
  final String? error;
}

class ModelsCubit extends Cubit<ModelsState> {
  ModelsCubit(this.repository, this.builtIns)
    : super(ModelsState(builtIns: builtIns, loading: true)) {
    load();
  }
  final ModelRepository repository;
  final List<BuiltInModel> builtIns;
  StreamSubscription<List<SavedModel>>? _subscription;
  void load() {
    _subscription?.cancel();
    emit(ModelsState(models: state.models, builtIns: builtIns, loading: true));
    _subscription = repository.watchModels().listen(
      (models) {
        if (!isClosed) emit(ModelsState(models: models, builtIns: builtIns));
      },
      onError: (Object error) {
        if (!isClosed) {
          emit(
            ModelsState(
              models: state.models,
              builtIns: builtIns,
              error: 'Could not load your model library. Try again.',
            ),
          );
        }
      },
    );
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    await super.close();
  }
}

class InspectionState {
  const InspectionState({this.data, this.error});
  final ModelInspection? data;
  final String? error;
}

class InspectionCubit extends Cubit<InspectionState> {
  InspectionCubit(this.engine, this.repository, this.model)
    : super(const InspectionState()) {
    load();
  }
  final TokenizerEngine engine;
  final ModelRepository repository;
  final SavedModel model;
  Future<void> load() async {
    emit(const InspectionState());
    try {
      final data = await engine.inspect(repository.modelPath(model));
      if (!isClosed) emit(InspectionState(data: data));
    } catch (error) {
      if (!isClosed) {
        emit(
          InspectionState(
            error: error is AppFailure
                ? error.message
                : 'Could not inspect this model.',
          ),
        );
      }
    }
  }
}
