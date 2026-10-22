import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../../../core/presentation/components.dart';

class TokenizationResults extends StatefulWidget {
  const TokenizationResults({
    super.key,
    required this.result,
    this.compact = false,
  });
  final bool compact;
  final TokenizationResult result;
  @override
  State<TokenizationResults> createState() => _TokenizationResultsState();
}

class _TokenizationResultsState extends State<TokenizationResults> {
  int _page = 0;
  int get _pageSize => widget.compact ? 64 : 150;
  @override
  void didUpdateWidget(covariant TokenizationResults oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.result != widget.result) _page = 0;
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final start = _page * _pageSize;
    final end = (start + _pageSize).clamp(0, result.ids.length);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.compact)
          _CompactMetrics(result: result)
        else
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              MetricTile('Tokens', '${result.ids.length}'),
              MetricTile(
                'Encoding time',
                '${(result.elapsedMicroseconds / 1000).toStringAsFixed(2)} ms',
              ),
              MetricTile(
                'Round-trip',
                result.roundTrip ? 'Exact match ✓' : 'Mismatch',
              ),
              for (final entry in result.metrics.entries)
                MetricTile(entry.key, formatNumber(entry.value)),
            ],
          ),
        if (widget.compact)
          ExpansionTile(
            title: const Text('All metrics'),
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final entry in result.metrics.entries)
                    MetricTile(entry.key, formatNumber(entry.value)),
                ],
              ),
            ],
          ),
        const SizedBox(height: 16),
        SurfaceCard(
          padding: widget.compact ? 16 : 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Token stream',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 6),
              Text(
                result.supportsTokenDetails
                    ? 'Tap a token to inspect its bytes. Quotes expose spaces and escaped characters.'
                    : 'Token IDs in sequence. The decoded text below shows the complete output.',
              ),
              const SizedBox(height: 18),
              if (result.ids.isEmpty)
                const Text('Empty input produces no tokens.')
              else
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = start; i < end; i++)
                      if (result.supportsTokenDetails)
                        TokenBadge(
                          result.pieces[i],
                          index: i,
                          onTap: () => showToken(context, result.pieces[i]),
                        )
                      else
                        Chip(
                          label: Text(
                            '#${result.ids[i]}',
                            style: const TextStyle(fontFamily: 'monospace'),
                          ),
                        ),
                  ],
                ),
              if (result.ids.length > _pageSize)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Row(
                    children: [
                      Text('${start + 1}–$end of ${result.ids.length}'),
                      const Spacer(),
                      IconButton(
                        tooltip: 'Previous tokens',
                        onPressed: _page == 0
                            ? null
                            : () => setState(() => _page--),
                        icon: const Icon(Icons.chevron_left),
                      ),
                      IconButton(
                        tooltip: 'Next tokens',
                        onPressed: end >= result.ids.length
                            ? null
                            : () => setState(() => _page++),
                        icon: const Icon(Icons.chevron_right),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 18),
              StatusMessage(
                result.supportsTokenDetails
                    ? 'A token can contain only part of a UTF-8 character. Those tokens show hex bytes; decoding the full sequence restores the text.'
                    : 'Built-in tokenizers provide IDs, decoded text, and metrics. Vocabulary, merge rules, and per-token byte inspection are available for custom BPE models.',
              ),
              const SizedBox(height: 12),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Token IDs'),
                trailing: IconButton(
                  tooltip: 'Copy all token IDs',
                  icon: const Icon(Icons.copy_outlined),
                  onPressed: () async {
                    await Clipboard.setData(
                      ClipboardData(text: result.ids.join(', ')),
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Token IDs copied')),
                      );
                    }
                  },
                ),
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: SelectableText(
                      result.ids.join(', '),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ],
              ),
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: const Text('Decoded text'),
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: SelectableText(result.decoded),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactMetrics extends StatelessWidget {
  const _CompactMetrics({required this.result});
  final TokenizationResult result;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: 14,
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, value) in [
          ('Tokens', '${result.ids.length}'),
          (
            'Encode',
            '${(result.elapsedMicroseconds / 1000).toStringAsFixed(2)} ms',
          ),
          ('Round-trip', result.roundTrip ? 'Match ✓' : 'Mismatch'),
        ])
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xff666779),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
