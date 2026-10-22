import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../../../core/presentation/components.dart';
import 'models_cubit.dart';
import 'model_actions.dart';
import 'entry_browser.dart';

class ModelDetailsPage extends StatelessWidget {
  const ModelDetailsPage({
    super.key,
    required this.model,
    required this.modelPath,
    required this.onUse,
  });
  final SavedModel model;
  final String modelPath;
  final ValueChanged<SavedModel> onUse;
  @override
  Widget build(BuildContext context) => BlocBuilder<ModelsCubit, ModelsState>(
    builder: (context, library) {
      final model =
          library.models.where((m) => m.id == this.model.id).firstOrNull ??
          this.model;
      return DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: Text(model.name),
            actions: [
              IconButton(
                tooltip: 'Use in tokenizer',
                onPressed: () => onUse(model),
                icon: const Icon(Icons.bolt),
              ),
              ModelActions(
                model: model,
                onDeleted: () => Navigator.of(context).pop(),
              ),
              const SizedBox(width: 12),
            ],
            bottom: const TabBar(
              tabs: [
                Tab(text: 'Overview'),
                Tab(text: 'Vocabulary'),
                Tab(text: 'Merge rules'),
              ],
            ),
          ),
          body: BlocBuilder<InspectionCubit, InspectionState>(
            builder: (context, state) => TabBarView(
              children: [
                _Overview(model: model, path: modelPath),
                _InspectionView(state: state, merges: false),
                _InspectionView(state: state, merges: true),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _Overview extends StatelessWidget {
  const _Overview({required this.model, required this.path});
  final SavedModel model;
  final String path;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(28),
    children: [
      SectionHeading(
        model.name,
        'Byte-level BPE · ${formatDate(model.createdAt)}',
        eyebrow: 'MODEL / OVERVIEW',
      ),
      Wrap(
        spacing: 12,
        runSpacing: 12,
        children: [
          MetricTile('Actual vocabulary', '${model.vocabularySize}'),
          MetricTile('Target vocabulary', '${model.targetVocabularySize}'),
          MetricTile('Merge rules', '${model.merges}'),
          MetricTile(
            'Training time',
            '${(model.trainingMilliseconds / 1000).toStringAsFixed(2)} s',
          ),
          MetricTile('Corpus bytes', formatBytes(model.corpusBytes)),
          MetricTile('Corpus characters', '${model.corpusCharacters}'),
          MetricTile('Minimum pair frequency', '${model.minPairFrequency}'),
          MetricTile('Model file', formatBytes(model.fileBytes)),
        ],
      ),
      const SizedBox(height: 24),
      if (model.vocabularySize < model.targetVocabularySize) ...[
        const StatusMessage(
          'The vocabulary is smaller than the target because no remaining pair met the minimum frequency.',
        ),
        const SizedBox(height: 24),
      ],
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Training sources',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Files were joined in this order with one newline between them. The corpus totals include those separators. Original file contents are not retained by the app.',
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < model.sources.length; i++)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text('${i + 1}. ${model.sources[i].name}'),
                subtitle: Text(
                  '${formatBytes(model.sources[i].bytes)} · ${model.sources[i].characters} characters · ${model.sources[i].lines} lines',
                ),
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: SelectableText(
                      'SHA-256\n${model.sources[i].sha256}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
      const SizedBox(height: 20),
      SurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Embedding estimate',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 10),
            Text(
              '${model.vocabularySize} tokens × ${model.embeddingDimensions} dimensions × ${model.bytesPerWeight} bytes = ${formatBytes(model.estimatedEmbeddingBytes)}',
            ),
            const SizedBox(height: 8),
            const Text(
              'Estimate for a single embedding matrix using the actual vocabulary. No embedding weights are trained or stored.',
            ),
            const SizedBox(height: 24),
            Text(
              'Local model file',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SelectableText(
              path,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
            const Text('The JSON file uses the dart_tokenizer model format.'),
          ],
        ),
      ),
    ],
  );
}

class _InspectionView extends StatelessWidget {
  const _InspectionView({required this.state, required this.merges});
  final InspectionState state;
  final bool merges;
  @override
  Widget build(BuildContext context) {
    if (state.error != null) {
      return Padding(
        padding: const EdgeInsets.all(28),
        child: Align(
          alignment: Alignment.topCenter,
          child: StatusMessage(
            state.error!,
            error: true,
            action: TextButton(
              onPressed: context.read<InspectionCubit>().load,
              child: const Text('Retry'),
            ),
          ),
        ),
      );
    }
    if (state.data == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return EntryBrowser(data: state.data!, showMerges: merges);
  }
}
