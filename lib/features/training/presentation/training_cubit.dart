import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../application/train_model.dart';
import '../domain/corpus_picker.dart';

enum TrainingPhase { idle, picking, training, saving, completed }

class TrainingState {
  const TrainingState({
    this.documents = const [],
    this.phase = TrainingPhase.idle,
    this.progress = const TrainingProgress(),
    this.error,
    this.saved,
  });
  final List<CorpusDocument> documents;
  final TrainingPhase phase;
  final TrainingProgress progress;
  final String? error;
  final SavedModel? saved;
  bool get busy =>
      phase == TrainingPhase.training ||
      phase == TrainingPhase.saving ||
      phase == TrainingPhase.picking;
}

class TrainingCubit extends Cubit<TrainingState> {
  TrainingCubit(this.picker, this.trainModel) : super(const TrainingState());
  final CorpusPicker picker;
  final TrainModel trainModel;
  CancellationSignal? _cancellation;

  void refreshModels(List<SavedModel> models) {
    if (state.saved == null) return;
    final updated = models.where((m) => m.id == state.saved!.id).firstOrNull;
    emit(
      TrainingState(
        documents: state.documents,
        progress: state.progress,
        phase: updated == null && state.phase == TrainingPhase.completed
            ? TrainingPhase.idle
            : state.phase,
        error: state.error,
        saved: updated,
      ),
    );
  }

  Future<void> addFiles() => _addDocuments(picker.pick);

  Future<void> addDroppedFiles(List<CorpusFileReference> files) =>
      _addDocuments(() => picker.readDroppedFiles(files));

  Future<void> _addDocuments(
    Future<List<CorpusDocument>> Function() read,
  ) async {
    if (state.busy) return;
    final existing = state.documents;
    emit(TrainingState(documents: existing, phase: TrainingPhase.picking));
    try {
      final added = await read();
      final all = [...existing];
      for (final document in added) {
        if (!all.any((d) => d.source.sha256 == document.source.sha256)) {
          all.add(document);
        }
      }
      if (all.fold<int>(0, (sum, d) => sum + d.source.bytes) >
          20 * 1024 * 1024) {
        throw const AppFailure(
          'The combined corpus must be no larger than 20 MiB.',
        );
      }
      if (!isClosed) emit(TrainingState(documents: List.unmodifiable(all)));
    } catch (error) {
      if (!isClosed) {
        emit(TrainingState(documents: existing, error: _message(error)));
      }
    }
  }

  void removeFile(int index) {
    if (state.busy) return;
    emit(TrainingState(documents: [...state.documents]..removeAt(index)));
  }

  Future<void> start(TrainingSettings settings) async {
    if (state.busy) return;
    final documents = state.documents;
    final cancellation = CancellationSignal();
    _cancellation = cancellation;
    emit(TrainingState(documents: documents, phase: TrainingPhase.training));
    try {
      final saved = await trainModel(
        settings,
        documents,
        cancellation,
        (progress) {
          if (!isClosed) {
            emit(
              TrainingState(
                documents: documents,
                phase: TrainingPhase.training,
                progress: progress,
              ),
            );
          }
        },
        () {
          if (!isClosed) {
            emit(
              TrainingState(
                documents: documents,
                phase: TrainingPhase.saving,
                progress: state.progress,
              ),
            );
          }
        },
      );
      if (!isClosed) {
        emit(
          TrainingState(
            documents: documents,
            phase: TrainingPhase.completed,
            progress: state.progress,
            saved: saved,
          ),
        );
      }
    } on TrainingCancelled {
      if (!isClosed) {
        emit(
          TrainingState(
            documents: documents,
            error: 'Training cancelled. Your corpus is ready to try again.',
          ),
        );
      }
    } catch (error) {
      if (!isClosed) {
        emit(TrainingState(documents: documents, error: _message(error)));
      }
    } finally {
      _cancellation = null;
    }
  }

  void cancel() {
    if (state.phase == TrainingPhase.training) _cancellation?.cancel();
  }

  @override
  Future<void> close() {
    _cancellation?.cancel();
    return super.close();
  }
}

String _message(Object error) => error is AppFailure
    ? error.message
    : 'Something went wrong. Please try again.';
