import 'package:flutter/material.dart';

import '../domain/tokenizer_entities.dart';

String formatBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KiB';
  return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MiB';
}

String formatDate(DateTime date) {
  final d = date.toLocal();
  return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')} '
      '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

String formatNumber(num value) =>
    value is int ? '$value' : value.toStringAsFixed(2);

class SectionHeading extends StatelessWidget {
  const SectionHeading(this.title, this.subtitle, {super.key, this.eyebrow});
  final String title, subtitle;
  final String? eyebrow;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 24),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
        ],
        Text(
          title,
          style: Theme.of(context).textTheme.headlineLarge
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: -1),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: Theme.of(context).textTheme.bodyLarge
              ?.copyWith(color: const Color(0xff666779)),
        ),
      ],
    ),
  );
}

class SurfaceCard extends StatelessWidget {
  const SurfaceCard({super.key, required this.child, this.padding = 24});
  final Widget child;
  final double padding;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: Color(0xffE5E5EC)),
    ),
    child: Padding(padding: EdgeInsets.all(padding), child: child),
  );
}

class StatusMessage extends StatelessWidget {
  const StatusMessage(
    this.message, {
    super.key,
    this.error = false,
    this.action,
  });
  final String message;
  final bool error;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: error ? const Color(0xffffeded) : const Color(0xffeeebff),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          error ? Icons.error_outline : Icons.info_outline,
          size: 20,
          color: error ? const Color(0xffb13333) : const Color(0xff6551c4),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(message)),
        ?action,
      ],
    ),
  );
}

class MetricTile extends StatelessWidget {
  const MetricTile(this.label, this.value, {super.key});
  final String label, value;
  @override
  Widget build(BuildContext context) => Container(
    constraints: const BoxConstraints(minWidth: 140),
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
    decoration: BoxDecoration(
      color: const Color(0xfff5f4fa),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Color(0xff666779)),
        ),
      ],
    ),
  );
}

class EmptyPanel extends StatelessWidget {
  const EmptyPanel({
    super.key,
    required this.title,
    required this.message,
    this.action,
    this.icon = Icons.auto_awesome_outlined,
  });
  final String title, message;
  final IconData icon;
  final Widget? action;
  @override
  Widget build(BuildContext context) => SurfaceCard(
    child: SizedBox(
      width: double.infinity,
      child: Column(
        children: [
          const SizedBox(height: 20),
          Icon(icon, size: 44, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 16),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center),
          if (action != null) ...[const SizedBox(height: 20), action!],
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

class TokenBadge extends StatelessWidget {
  const TokenBadge(this.token, {super.key, this.index = 0, this.onTap});
  final TokenPiece token;
  final int index;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    const colors = [
      Color(0xffe9e2ff),
      Color(0xffdff2ec),
      Color(0xffffedce),
      Color(0xffdfeaff),
      Color(0xffffe3ed),
    ];
    final label = token.text == null ? '0x${token.hex}' : token.display;
    return Tooltip(
      message:
          'Token #${token.id}\nUTF-8 bytes: ${token.bytes.join(', ')}\nHex: ${token.hex}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(9),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          constraints: const BoxConstraints(maxWidth: 260),
          decoration: BoxDecoration(
            color: colors[index % colors.length],
            borderRadius: BorderRadius.circular(9),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 14),
              ),
              Text(
                '#${token.id}',
                style: const TextStyle(fontSize: 10, color: Color(0xff606070)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

void showToken(BuildContext context, TokenPiece token) => showDialog<void>(
  context: context,
  builder: (context) => AlertDialog(
    title: Text('Token #${token.id}'),
    content: SizedBox(
      width: 480,
      child: SingleChildScrollView(
        child: SelectableText(
          'Readable text: ${token.display}\n\nValid UTF-8: ${token.isValidUtf8 ? 'Yes' : 'No — byte fragment'}'
          '\n\nDecimal bytes: ${token.bytes.join(', ')}\n\nHex: ${token.hex}',
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Close'),
      ),
    ],
  ),
);
