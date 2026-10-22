import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../../../core/domain/tokenizer_engine.dart';
import '../../../core/presentation/components.dart';
import '../domain/model_repository.dart';
import 'models_cubit.dart';
import 'model_actions.dart';
import 'model_details_page.dart';
import 'built_in_models_section.dart';

class ModelsPage extends StatelessWidget {
  const ModelsPage({
    super.key,
    required this.onCreate,
    required this.onUseModel,
  });
  final VoidCallback onCreate;
  final void Function(ModelOption) onUseModel;
  @override
  Widget build(BuildContext context) => BlocBuilder<ModelsCubit, ModelsState>(
    builder: (context, state) {
      return ListView(
        padding: const EdgeInsets.all(28),
        children: [
          const SectionHeading(
            'Your model library.',
            'Built-in tokenizers and your locally trained BPE models.',
            eyebrow: 'WORKSPACE / MODELS',
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text('Create a model'),
            ),
          ),
          const SizedBox(height: 24),
          if (state.builtIns.isNotEmpty) ...[
            BuiltInModelsSection(models: state.builtIns, onUse: onUseModel),
            const SizedBox(height: 28),
          ],
          Text('Custom models', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          if (state.loading) const LinearProgressIndicator(),
          if (state.error != null)
            StatusMessage(
              state.error!,
              error: true,
              action: TextButton(
                onPressed: context.read<ModelsCubit>().load,
                child: const Text('Retry'),
              ),
            ),
          if (!state.loading && state.error == null && state.models.isEmpty)
            const EmptyPanel(
              title: 'A library of your own',
              message: 'Models you train will be saved here, along with their vocabulary and corpus history.',
              icon: Icons.inventory_2_outlined,
            ),
          for (final model in state.models)
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SurfaceCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xffeeebff),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.hub_outlined,
                            color: Color(0xff6551c4),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                model.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Byte-level BPE · Created ${formatDate(model.createdAt)}',
                                style: const TextStyle(
                                  color: Color(0xff666779),
                                ),
                              ),
                            ],
                          ),
                        ),
                        ModelActions(model: model),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 20,
                      runSpacing: 8,
                      children: [
                        Text('${model.vocabularySize} tokens'),
                        Text('${model.merges} merge rules'),
                        Text('${model.sources.length} source files'),
                        Text('${formatBytes(model.corpusBytes)} corpus'),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => BlocProvider(
                                create: (_) => InspectionCubit(
                                  context.read<TokenizerEngine>(),
                                  context.read<ModelRepository>(),
                                  model,
                                ),
                                child: ModelDetailsPage(
                                  model: model,
                                  modelPath: context
                                      .read<ModelRepository>()
                                      .modelPath(model),
                                  onUse: (selected) {
                                    Navigator.of(context).pop();
                                    onUseModel(selected);
                                  },
                                ),
                              ),
                            ),
                          ),
                          child: const Text('Inspect model'),
                        ),
                        TextButton.icon(
                          onPressed: () => onUseModel(model),
                          icon: const Icon(Icons.bolt),
                          label: const Text('Use in tokenizer'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      );
    },
  );
}
