import 'package:flutter/material.dart';

import '../../../../core/presentation/components.dart';
import '../comparison_cubit.dart';

class ComparisonInput extends StatelessWidget {
  const ComparisonInput({
    super.key,
    required this.controller,
    required this.state,
    required this.expanded,
    required this.onToggle,
    required this.onChanged,
    required this.onCompare,
    required this.onSwap,
  });
  final TextEditingController controller;
  final ComparisonState state;
  final bool expanded;
  final VoidCallback onToggle, onCompare, onSwap;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: 16,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.notes, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                expanded
                    ? 'Shared input'
                    : 'Shared input · ${state.input.runes.length} characters',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              tooltip: expanded ? 'Collapse input' : 'Edit shared input',
              onPressed: onToggle,
              icon: Icon(expanded ? Icons.unfold_less : Icons.edit_outlined),
            ),
          ],
        ),
        if (expanded) ...[
          const SizedBox(height: 8),
          TextField(
            key: const ValueKey('comparison-input'),
            controller: controller,
            minLines: 2,
            maxLines: 5,
            onChanged: onChanged,
            decoration: const InputDecoration(
              labelText: 'Text for both models',
              alignLabelWithHint: true,
              hintText: 'Enter the same text once and compare how two tokenizers handle it.',
            ),
          ),
          const SizedBox(height: 12),
        ],
        Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: state.canCompare ? onCompare : null,
              icon: state.busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.compare_arrows),
              label: Text(state.busy ? 'Comparing…' : 'Compare models'),
            ),
            TextButton.icon(
              onPressed: state.busy ? null : onSwap,
              icon: const Icon(Icons.swap_horiz),
              label: const Text('Swap A / B'),
            ),
            const Text(
              'Identical input · independent results',
              style: TextStyle(fontSize: 12, color: Color(0xff666779)),
            ),
          ],
        ),
        if (state.error != null) ...[
          const SizedBox(height: 12),
          StatusMessage(state.error!, error: true),
        ],
      ],
    ),
  );
}
