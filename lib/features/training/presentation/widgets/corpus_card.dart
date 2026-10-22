import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:desktop_drop/desktop_drop.dart';

import '../../../../core/presentation/components.dart';
import '../training_cubit.dart';
import '../../domain/corpus_picker.dart';

class CorpusCard extends StatefulWidget {
  const CorpusCard({
    super.key,
    required this.state,
    required this.onAdd,
    required this.onRemove,
    required this.onDrop,
    this.active = true,
  });
  final TrainingState state;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<List<CorpusFileReference>> onDrop;
  final bool active;
  @override
  State<CorpusCard> createState() => _CorpusCardState();
}

class _CorpusCardState extends State<CorpusCard> {
  bool _hovering = false;
  bool get _desktop => [
    TargetPlatform.macOS,
    TargetPlatform.windows,
    TargetPlatform.linux,
  ].contains(defaultTargetPlatform);
  @override
  void didUpdateWidget(covariant CorpusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.active || widget.state.busy) _hovering = false;
  }

  @override
  Widget build(BuildContext context) {
    final bytes = widget.state.documents.fold<int>(
      0,
      (sum, d) => sum + d.source.bytes,
    );
    final card = SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '02  Add training text',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          const Text(
            'UTF-8 text files · up to 20 MiB total\nFiles are joined in order with one newline between them.',
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: widget.state.busy ? null : widget.onAdd,
            icon: const Icon(Icons.upload_file_outlined),
            label: Text(
              widget.state.phase == TrainingPhase.picking
                  ? 'Reading files…'
                  : 'Add text files',
            ),
          ),
          const SizedBox(height: 16),
          AnimatedContainer(
            key: const ValueKey('corpus-drop-zone'),
            duration: const Duration(milliseconds: 160),
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
            decoration: BoxDecoration(
              color: _hovering
                  ? const Color(0xffe6dfff)
                  : const Color(0xfff6f5fa),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _hovering
                    ? const Color(0xff6951d1)
                    : const Color(0xffdcd9e8),
                width: _hovering ? 2 : 1,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  _hovering
                      ? Icons.file_download_outlined
                      : Icons.upload_file_outlined,
                  size: 32,
                  color: const Color(0xff8171b5),
                ),
                const SizedBox(height: 10),
                Text(
                  widget.state.busy
                      ? 'Corpus is locked while working'
                      : _hovering
                      ? 'Release to add your files'
                      : _desktop
                      ? 'Drag & drop text files here'
                      : 'Add text files to build your corpus',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                const Text(
                  '.txt · .md · .csv · .text',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
          if (widget.state.documents.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                MetricTile('Source files', '${widget.state.documents.length}'),
                MetricTile('Corpus size', formatBytes(bytes)),
              ],
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < widget.state.documents.length; i++)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.article_outlined),
                title: Text(widget.state.documents[i].source.name),
                subtitle: Text(
                  '${formatBytes(widget.state.documents[i].source.bytes)} · ${widget.state.documents[i].source.characters} characters · ${widget.state.documents[i].source.lines} lines',
                ),
                trailing: IconButton(
                  tooltip: 'Remove file',
                  onPressed: widget.state.busy
                      ? null
                      : () => widget.onRemove(i),
                  icon: const Icon(Icons.close),
                ),
              ),
          ],
          const SizedBox(height: 18),
          const Text(
            'Identical files are included once. Source names, statistics, and SHA-256 fingerprints are saved with the model.',
            style: TextStyle(fontSize: 12, color: Color(0xff666779)),
          ),
        ],
      ),
    );
    if (!_desktop) return card;
    return DropTarget(
      enable: widget.active && !widget.state.busy,
      onDragEntered: (_) => setState(() => _hovering = true),
      onDragExited: (_) => setState(() => _hovering = false),
      onDragDone: (details) {
        setState(() => _hovering = false);
        if (widget.active && !widget.state.busy) {
          widget.onDrop(
            details.files
                .map(
                  (file) => CorpusFileReference(
                    file.path,
                    accessBookmark: file.extraAppleBookmark,
                  ),
                )
                .toList(),
          );
        }
      },
      child: card,
    );
  }
}
