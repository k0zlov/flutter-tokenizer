import 'package:flutter/material.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../../../core/presentation/components.dart';

class EntryBrowser extends StatefulWidget {
  const EntryBrowser({super.key, required this.data, required this.showMerges});
  final ModelInspection data;
  final bool showMerges;
  @override
  State<EntryBrowser> createState() => _EntryBrowserState();
}

class _EntryBrowserState extends State<EntryBrowser> {
  String _query = '';
  String _filter = 'all';
  int _page = 0;
  static const _size = 40;
  bool _accept(TokenPiece token) =>
      _filter == 'all' ||
      (_filter == 'valid' ? token.isValidUtf8 : !token.isValidUtf8);
  @override
  Widget build(BuildContext context) {
    final tokens = widget.showMerges
        ? const <TokenPiece>[]
        : widget.data.vocabulary
              .where((t) => t.matches(_query) && _accept(t))
              .toList();
    final merges = widget.showMerges
        ? widget.data.merges
              .where((m) => m.matches(_query) && _accept(m.result))
              .toList()
        : const <MergeEntry>[];
    final count = widget.showMerges ? merges.length : tokens.length;
    final start = _page * _size;
    final end = (start + _size).clamp(0, count);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  labelText: widget.showMerges
                      ? 'Search rank, token ID, text, decimal bytes, or hex'
                      : 'Search token ID, text, decimal bytes, or hex',
                ),
                onChanged: (value) => setState(() {
                  _query = value;
                  _page = 0;
                }),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  for (final (value, label) in [
                    ('all', 'All entries'),
                    ('valid', 'Valid UTF-8'),
                    ('partial', 'Byte fragments'),
                  ])
                    ChoiceChip(
                      label: Text(label),
                      selected: _filter == value,
                      onSelected: (_) => setState(() {
                        _filter = value;
                        _page = 0;
                      }),
                    ),
                ],
              ),
              if (widget.showMerges)
                const Padding(
                  padding: EdgeInsets.only(top: 8),
                  child: Text(
                    'UTF-8 filters apply to the result token. Lower ranks merge first.',
                    style: TextStyle(fontSize: 12),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: count == 0
              ? Center(
                  child: Text(
                    widget.showMerges && widget.data.merges.isEmpty
                        ? 'This model has no learned merge rules.'
                        : 'No entries match your search.',
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  itemCount: end - start,
                  itemBuilder: (context, index) {
                    final actual = start + index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: widget.showMerges
                          ? _MergeCard(merges[actual])
                          : _VocabularyCard(tokens[actual]),
                    );
                  },
                ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text(count == 0 ? '0 entries' : '${start + 1}–$end of $count'),
                const Spacer(),
                IconButton(
                  tooltip: 'Previous page',
                  onPressed: _page == 0 ? null : () => setState(() => _page--),
                  icon: const Icon(Icons.chevron_left),
                ),
                IconButton(
                  tooltip: 'Next page',
                  onPressed: end >= count
                      ? null
                      : () => setState(() => _page++),
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _VocabularyCard extends StatelessWidget {
  const _VocabularyCard(this.token);
  final TokenPiece token;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: 16,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ID ${token.id}',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                token.display,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            IconButton(
              tooltip: 'Inspect token',
              onPressed: () => showToken(context, token),
              icon: const Icon(Icons.open_in_full, size: 18),
            ),
          ],
        ),
        SelectableText(
          'Bytes: ${token.bytes.join(', ')}\nHex: ${token.hex}',
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
        if (!token.isValidUtf8)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              'Byte fragment · not valid UTF-8 by itself',
              style: TextStyle(fontSize: 12, color: Color(0xff936223)),
            ),
          ),
      ],
    ),
  );
}

class _MergeCard extends StatelessWidget {
  const _MergeCard(this.merge);
  final MergeEntry merge;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: 16,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'RANK ${merge.rank}     #${merge.left.id} + #${merge.right.id} → #${merge.result.id}',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            for (final (label, token) in [
              ('Left', merge.left),
              ('Right', merge.right),
              ('Result', merge.result),
            ])
              SizedBox(
                width: 210,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xff666779),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TokenBadge(
                      token,
                      index: token.id,
                      onTap: () => showToken(context, token),
                    ),
                    const SizedBox(height: 6),
                    SelectableText(
                      'Bytes: ${token.bytes.join(', ')}\nHex: ${token.hex}',
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    ),
  );
}
