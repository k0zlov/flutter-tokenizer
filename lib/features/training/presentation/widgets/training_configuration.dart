import 'package:flutter/material.dart';

import '../../../../core/presentation/components.dart';

class TrainingConfiguration extends StatelessWidget {
  const TrainingConfiguration({
    super.key,
    required this.busy,
    required this.nameController,
    required this.vocabularyController,
    required this.frequencyController,
    required this.dimensionsController,
    required this.precision,
    required this.onPrecisionChanged,
    required this.onEstimateChanged,
  });
  final bool busy;
  final TextEditingController nameController,
      vocabularyController,
      frequencyController,
      dimensionsController;
  final int precision;
  final ValueChanged<int> onPrecisionChanged;
  final VoidCallback onEstimateChanged;
  String? validateInteger(String? value, int min, int max) {
    final n = int.tryParse(value ?? '');
    return n == null || n < min || n > max
        ? 'Enter a whole number from $min to $max'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final estimatedBytes =
        (int.tryParse(vocabularyController.text) ?? 0) *
        (int.tryParse(dimensionsController.text) ?? 0) *
        precision;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('01  Configure', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 22),
          TextFormField(
            controller: nameController,
            enabled: !busy,
            maxLength: 80,
            decoration: const InputDecoration(
              labelText: 'Model name',
              hintText: 'e.g. Literature · English',
            ),
            validator: (s) =>
                s == null || s.trim().isEmpty ? 'Give your model a name' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: vocabularyController,
            enabled: !busy,
            keyboardType: TextInputType.number,
            onChanged: (_) => onEstimateChanged(),
            validator: (s) => validateInteger(s, 256, 32768),
            decoration: const InputDecoration(
              labelText: 'Target vocabulary size',
              helperText: 'Includes the 256 base byte tokens.',
            ),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: frequencyController,
            enabled: !busy,
            keyboardType: TextInputType.number,
            validator: (s) => validateInteger(s, 1, 1000000),
            decoration: const InputDecoration(
              labelText: 'Minimum pair frequency',
              helperText: 'Stop when no pair meets this frequency.',
            ),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 12),
          Text(
            'Embedding size estimate',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          const Text(
            'Planning only. BPE learns tokens and merge rules; it does not train embedding weights.',
          ),
          const SizedBox(height: 18),
          TextFormField(
            controller: dimensionsController,
            enabled: !busy,
            keyboardType: TextInputType.number,
            onChanged: (_) => onEstimateChanged(),
            validator: (s) => validateInteger(s, 1, 16384),
            decoration: const InputDecoration(
              labelText: 'Embedding dimensions',
            ),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<int>(
            isExpanded: true,
            initialValue: precision,
            decoration: const InputDecoration(
              labelText: 'Weight precision (estimate only)',
            ),
            items: const [
              DropdownMenuItem(value: 4, child: Text('Float32 · 4 bytes')),
              DropdownMenuItem(value: 2, child: Text('Float16 · 2 bytes')),
            ],
            onChanged: busy ? null : (value) => onPrecisionChanged(value!),
          ),
          const SizedBox(height: 12),
          const Text(
            'Each embedding weight is a number. Float16 stores it in 16 bits (2 bytes); Float32 uses 32 bits (4 bytes), with more numerical precision. Float16 needs half the memory.',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 8),
          const Text(
            'This setting only changes the estimate below. It does not change training, token IDs, vocabulary, or the saved tokenizer file.',
            style: TextStyle(fontSize: 12, height: 1.5),
          ),
          const SizedBox(height: 16),
          StatusMessage(
            '${formatBytes(estimatedBytes < 0 ? 0 : estimatedBytes)} estimated for one matrix\nVocabulary × dimensions × bytes per weight',
          ),
        ],
      ),
    );
  }
}
