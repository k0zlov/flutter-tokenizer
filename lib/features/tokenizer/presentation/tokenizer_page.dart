import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/components.dart';
import '../../models/presentation/models_cubit.dart';
import 'tokenizer_cubit.dart';
import 'tokenization_results.dart';

class TokenizerPage extends StatefulWidget {
  const TokenizerPage({super.key, required this.onCreate});
  final VoidCallback onCreate;
  @override
  State<TokenizerPage> createState() => _TokenizerPageState();
}

class _TokenizerPageState extends State<TokenizerPage> {
  final _text = TextEditingController();
  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ModelsCubit, ModelsState>(
    builder: (context, library) {
      return BlocBuilder<TokenizerCubit, TokenizerState>(
        builder: (context, state) {
          final cubit = context.read<TokenizerCubit>();
          return ListView(
            padding: const EdgeInsets.all(28),
            children: [
              const SectionHeading(
                'Make language visible.',
                'Explore how built-in and custom models turn text into tokens.',
                eyebrow: 'WORKSPACE / TOKENIZER',
              ),
              if (library.loading) const LinearProgressIndicator(),
              if (library.error != null)
                StatusMessage(
                  library.error!,
                  error: true,
                  action: TextButton(
                    onPressed: context.read<ModelsCubit>().load,
                    child: const Text('Retry'),
                  ),
                ),
              if (!library.loading &&
                  library.error == null &&
                  library.options.isEmpty)
                EmptyPanel(
                  title: 'Your first model starts here',
                  message: 'Train a BPE model on your own text, then explore its tokens.',
                  action: FilledButton.icon(
                    onPressed: widget.onCreate,
                    icon: const Icon(Icons.add),
                    label: const Text('Create a model'),
                  ),
                )
              else ...[
                SurfaceCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.memory_outlined, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Model & input',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      DropdownButtonFormField<String>(
                        key: ValueKey(state.model?.id),
                        initialValue: state.model?.id,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          labelText: 'Tokenizer model',
                        ),
                        hint: const Text('Select a tokenizer model'),
                        items: [
                          for (final m in library.options)
                            DropdownMenuItem(
                              value: m.id,
                              child: Text(
                                m.selectionLabel,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                        onChanged: (id) {
                          if (id != null) {
                            cubit.select(
                              library.options.firstWhere((m) => m.id == id),
                            );
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        controller: _text,
                        minLines: 5,
                        maxLines: 12,
                        onChanged: (_) => cubit.textChanged(),
                        decoration: const InputDecoration(
                          labelText: 'Text to tokenize',
                          alignLabelWithHint: true,
                          hintText: 'Try a sentence, a little code, or a multilingual phrase…',
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 12,
                        runSpacing: 10,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: state.model == null || state.busy
                                ? null
                                : () => cubit.tokenize(_text.text),
                            icon: state.busy
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Icon(Icons.bolt),
                            label: Text(
                              state.busy ? 'Tokenizing…' : 'Tokenize text',
                            ),
                          ),
                          TextButton(
                            onPressed: state.busy
                                ? null
                                : () {
                                    _text.text = 'Hello, world! Привіт, світе! 👋\nTokens make language computable.';
                                    cubit.textChanged();
                                  },
                            child: const Text('Try an example'),
                          ),
                          const Text(
                            'Runs locally on your device',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xff777888),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (state.error != null) ...[
                  const SizedBox(height: 16),
                  StatusMessage(state.error!, error: true),
                ],
                const SizedBox(height: 24),
                if (state.result case final result?)
                  TokenizationResults(result: result)
                else if (!state.busy)
                  const EmptyPanel(
                    title: 'See every piece',
                    message: 'Your tokens, byte values, and round-trip check will appear here.',
                    icon: Icons.data_array,
                  ),
              ],
            ],
          );
        },
      );
    },
  );
}
