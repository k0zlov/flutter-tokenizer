import 'package:flutter/material.dart';

import '../../../../core/domain/tokenizer_entities.dart';
import '../../../../core/presentation/components.dart';
import '../../../tokenizer/presentation/tokenization_results.dart';
import '../comparison_cubit.dart';

class ComparisonPane extends StatefulWidget {
  const ComparisonPane({
    super.key,
    required this.label,
    required this.slot,
    required this.options,
    required this.onSelect,
    required this.scrollResults,
  });
  final String label;
  final ComparisonSlot slot;
  final List<ModelOption> options;
  final ValueChanged<ModelOption> onSelect;
  final bool scrollResults;
  @override
  State<ComparisonPane> createState() => _ComparisonPaneState();
}

class _ComparisonPaneState extends State<ComparisonPane> {
  final _scroll = ScrollController();
  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ComparisonPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.slot.result != widget.slot.result && _scroll.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && _scroll.hasClients) _scroll.jumpTo(0);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final slot = widget.slot;
    final Widget content;
    if (slot.busy) {
      content = const SurfaceCard(
        child: Column(
          children: [
            LinearProgressIndicator(),
            SizedBox(height: 20),
            Text('Tokenizing the shared input…'),
          ],
        ),
      );
    } else if (slot.error != null) {
      content = StatusMessage(slot.error!, error: true);
    } else if (slot.result case final result?) {
      content = TokenizationResults(result: result, compact: true);
    } else {
      content = const EmptyPanel(
        title: 'Ready to compare',
        message: 'Choose a model above, then compare the shared input.',
        icon: Icons.compare_arrows,
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SurfaceCard(
          padding: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MODEL ${widget.label}',
                style: TextStyle(
                  fontSize: 11,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w800,
                  color: widget.label == 'A'
                      ? const Color(0xff6951d1)
                      : const Color(0xff247c68),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                key: ValueKey('${widget.label}:${slot.model?.id}'),
                initialValue: slot.model?.id,
                isExpanded: true,
                decoration: InputDecoration(labelText: 'Model ${widget.label}'),
                hint: const Text('Select a tokenizer'),
                items: [
                  for (final option in widget.options)
                    DropdownMenuItem(
                      value: option.id,
                      child: Text(
                        option.selectionLabel,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                onChanged: (id) {
                  if (id != null) {
                    widget.onSelect(
                      widget.options.firstWhere((m) => m.id == id),
                    );
                  }
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (widget.scrollResults)
          Expanded(
            child: Scrollbar(
              controller: _scroll,
              thumbVisibility: true,
              child: ListView(
                controller: _scroll,
                primary: false,
                padding: const EdgeInsets.only(right: 12, bottom: 12),
                children: [content],
              ),
            ),
          )
        else
          content,
      ],
    );
  }
}
