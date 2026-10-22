import 'package:flutter/material.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../../../core/presentation/components.dart';

class BuiltInModelsSection extends StatelessWidget {
  const BuiltInModelsSection({
    super.key,
    required this.models,
    required this.onUse,
  });
  final List<BuiltInModel> models;
  final ValueChanged<ModelOption> onUse;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Built-in tiktoken', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      const Text(
        'Always available on this device. Built-in tokenizers cannot be deleted and have no model details page.',
      ),
      const SizedBox(height: 16),
      for (final kind in BuiltInKind.values) ...[
        Text(
          kind == BuiltInKind.model ? 'Model presets' : 'Named encodings',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 10),
        for (final model in models.where((m) => m.kind == kind))
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SurfaceCard(
              padding: 16,
              child: Row(
                children: [
                  const Tooltip(
                    message: 'Built-in · cannot be deleted',
                    child: Icon(Icons.lock_outline, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          model.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          'tiktoken · ${model.encoding}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xff666779),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Use ${model.name}',
                    onPressed: () => onUse(model),
                    icon: const Icon(Icons.bolt),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
      ],
    ],
  );
}
