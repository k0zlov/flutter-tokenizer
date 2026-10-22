import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../../../core/presentation/components.dart';
import 'training_cubit.dart';
import 'widgets/training_configuration.dart';
import 'widgets/corpus_card.dart';

class TrainingPage extends StatefulWidget {
  const TrainingPage({super.key, required this.onUseModel, this.active = true});
  final bool active;
  final void Function(SavedModel) onUseModel;
  @override
  State<TrainingPage> createState() => _TrainingPageState();
}

class _TrainingPageState extends State<TrainingPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _vocabulary = TextEditingController(text: '1024');
  final _frequency = TextEditingController(text: '2');
  final _dimensions = TextEditingController(text: '256');
  int _precision = 4;
  @override
  void dispose() {
    for (final c in [_name, _vocabulary, _frequency, _dimensions]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) => BlocBuilder<TrainingCubit, TrainingState>(
    builder: (context, state) {
      final cubit = context.read<TrainingCubit>();
      return ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const SectionHeading(
            'Teach it your language.',
            'Build a byte-level BPE vocabulary from your own text files.',
            eyebrow: 'WORKSPACE / TRAIN A MODEL',
          ),
          Form(
            key: _form,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final configuration = TrainingConfiguration(
                  busy: state.busy,
                  nameController: _name,
                  vocabularyController: _vocabulary,
                  frequencyController: _frequency,
                  dimensionsController: _dimensions,
                  precision: _precision,
                  onPrecisionChanged: (value) =>
                      setState(() => _precision = value),
                  onEstimateChanged: () => setState(() {}),
                );
                final corpus = CorpusCard(
                  state: state,
                  onAdd: cubit.addFiles,
                  onRemove: cubit.removeFile,
                  onDrop: cubit.addDroppedFiles,
                  active: widget.active,
                );
                return constraints.maxWidth >= 900
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: configuration),
                          const SizedBox(width: 24),
                          Expanded(child: corpus),
                        ],
                      )
                    : Column(
                        children: [
                          configuration,
                          const SizedBox(height: 20),
                          corpus,
                        ],
                      );
              },
            ),
          ),
          const SizedBox(height: 24),
          if (state.error != null) ...[
            StatusMessage(state.error!, error: true),
            const SizedBox(height: 18),
          ],
          if (state.phase == TrainingPhase.training ||
              state.phase == TrainingPhase.saving)
            _ProgressCard(state: state, onCancel: cubit.cancel),
          if (state.saved case final model?) ...[
            StatusMessage(
              '“${model.name}” is saved. Learned ${model.vocabularySize} tokens and ${model.merges} merge rules.'
              '${model.vocabularySize < model.targetVocabularySize ? '\nTraining stopped before the target because no remaining pair met the minimum frequency.' : ''}',
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: () => widget.onUseModel(model),
                icon: const Icon(Icons.bolt),
                label: const Text('Use this model'),
              ),
            ),
            const SizedBox(height: 20),
          ],
          if (!state.busy)
            Align(
              alignment: Alignment.centerLeft,
              child: FilledButton.icon(
                onPressed: state.documents.isEmpty
                    ? null
                    : () {
                        if (_form.currentState!.validate()) {
                          cubit.start(
                            TrainingSettings(
                              name: _name.text,
                              vocabularySize: int.parse(_vocabulary.text),
                              minPairFrequency: int.parse(_frequency.text),
                              embeddingDimensions: int.parse(_dimensions.text),
                              bytesPerWeight: _precision,
                            ),
                          );
                        }
                      },
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Train & save model'),
              ),
            ),
          const SizedBox(height: 20),
        ],
      );
    },
  );
}

class _ProgressCard extends StatelessWidget {
  const _ProgressCard({required this.state, required this.onCancel});
  final TrainingState state;
  final VoidCallback onCancel;
  @override
  Widget build(BuildContext context) {
    final p = state.progress;
    final saving = state.phase == TrainingPhase.saving;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            saving ? 'Saving your model…' : p.stage,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 14),
          LinearProgressIndicator(value: saving ? null : p.fraction),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              MetricTile('Target merges', '${p.current} / ${p.total}'),
              MetricTile('Vocabulary', '${p.vocabularySize}'),
              MetricTile('Corpus tokens', '${p.remainingTokens}'),
              MetricTile(
                'Elapsed',
                '${(p.elapsedMilliseconds / 1000).toStringAsFixed(1)} s',
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Progress measures learned merges against the target. Training may finish early. You can explore other tabs while it runs.',
          ),
          if (!saving)
            TextButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.stop_circle_outlined),
              label: const Text('Cancel training'),
            ),
        ],
      ),
    );
  }
}
