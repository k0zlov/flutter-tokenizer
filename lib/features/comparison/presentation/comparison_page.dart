import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/presentation/components.dart';
import '../../models/presentation/models_cubit.dart';
import 'comparison_cubit.dart';
import 'widgets/comparison_input.dart';
import 'widgets/comparison_pane.dart';

class ComparisonPage extends StatefulWidget {
  const ComparisonPage({super.key});
  @override
  State<ComparisonPage> createState() => _ComparisonPageState();
}

class _ComparisonPageState extends State<ComparisonPage> {
  final _input = TextEditingController();
  bool _expandedInput = true;
  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => BlocBuilder<ModelsCubit, ModelsState>(
    builder: (context, library) =>
        BlocBuilder<ComparisonCubit, ComparisonState>(
          builder: (context, state) {
            final cubit = context.read<ComparisonCubit>();
            return LayoutBuilder(
              builder: (context, constraints) {
                final split =
                    constraints.maxWidth >= 900 && constraints.maxHeight >= 650;
                final header = Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Compare models.',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    const Text('One text. Two tokenizers. See the difference.'),
                    const SizedBox(height: 16),
                    ComparisonInput(
                      controller: _input,
                      state: state,
                      expanded: _expandedInput,
                      onToggle: () =>
                          setState(() => _expandedInput = !_expandedInput),
                      onChanged: cubit.changeInput,
                      onSwap: cubit.swap,
                      onCompare: () {
                        FocusScope.of(context).unfocus();
                        if (state.input.length <= 100000) {
                          setState(() => _expandedInput = false);
                        }
                        cubit.compare();
                      },
                    ),
                    if (library.error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: StatusMessage(
                          library.error!,
                          error: true,
                          action: TextButton(
                            onPressed: context.read<ModelsCubit>().load,
                            child: const Text('Retry'),
                          ),
                        ),
                      ),
                    if (state.left.result != null && state.right.result != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: _ComparisonSummary(state),
                      ),
                    const SizedBox(height: 16),
                  ],
                );
                Widget pane(String label, bool left) => ComparisonPane(
                  key: ValueKey('comparison-$label'),
                  label: label,
                  slot: left ? state.left : state.right,
                  options: library.options,
                  onSelect: (model) => cubit.select(left, model),
                  scrollResults: split,
                );
                if (split) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                    child: Column(
                      children: [
                        header,
                        Expanded(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: pane('A', true)),
                              const SizedBox(width: 20),
                              Expanded(child: pane('B', false)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    header,
                    pane('A', true),
                    const SizedBox(height: 24),
                    pane('B', false),
                    const SizedBox(height: 20),
                  ],
                );
              },
            );
          },
        ),
  );
}

class _ComparisonSummary extends StatelessWidget {
  const _ComparisonSummary(this.state);
  final ComparisonState state;
  @override
  Widget build(BuildContext context) {
    final a = state.left.result!.ids.length;
    final b = state.right.result!.ids.length;
    final difference = (a - b).abs();
    final baseline = a > b ? a : b;
    final text = a == b
        ? 'Both models produce $a tokens.'
        : 'Model ${a < b ? 'A' : 'B'} uses $difference fewer tokens (${(100 * difference / baseline).toStringAsFixed(1)}% fewer than ${a < b ? 'B' : 'A'}).';
    return Text(
      '$text  Token count alone does not measure model quality. Encoding timings are single-run observations.',
      style: const TextStyle(fontSize: 12, color: Color(0xff666779)),
    );
  }
}
