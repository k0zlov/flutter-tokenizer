import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/domain/tokenizer_engine.dart';
import 'features/comparison/presentation/comparison_cubit.dart';
import 'features/comparison/presentation/comparison_page.dart';
import 'features/tokenizer/application/tokenize_text.dart';
import 'core/domain/tokenizer_entities.dart';
import 'features/models/domain/model_repository.dart';
import 'features/models/presentation/models_cubit.dart';
import 'features/models/presentation/models_page.dart';
import 'features/tokenizer/presentation/tokenizer_cubit.dart';
import 'features/tokenizer/presentation/tokenizer_page.dart';
import 'features/training/application/train_model.dart';
import 'features/training/domain/corpus_picker.dart';
import 'features/training/presentation/training_cubit.dart';
import 'features/training/presentation/training_page.dart';

ThemeData tokenizerTheme() {
  final scheme = ColorScheme.fromSeed(
    seedColor: const Color(0xff6951d1),
    surface: const Color(0xfff8f8fb),
    brightness: Brightness.light,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: scheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xfffafafd),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffdedee8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xffdedee8)),
      ),
      contentPadding: const EdgeInsets.all(16),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

class TokenizerApp extends StatelessWidget {
  const TokenizerApp({
    super.key,
    required this.repository,
    required this.engine,
    required this.picker,
  });
  final ModelRepository repository;
  final TokenizerEngine engine;
  final CorpusPicker picker;
  @override
  Widget build(BuildContext context) => MultiRepositoryProvider(
    providers: [
      RepositoryProvider<ModelRepository>.value(value: repository),
      RepositoryProvider<TokenizerEngine>.value(value: engine),
    ],
    child: MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => ModelsCubit(repository, engine.builtInModels),
        ),
        BlocProvider(create: (_) => TokenizerCubit(engine, repository)),
        BlocProvider(
          create: (_) => ComparisonCubit(
            TokenizeText(engine, repository),
            engine.builtInModels,
          ),
        ),
        BlocProvider(
          create: (_) => TrainingCubit(picker, TrainModel(engine, repository)),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Tokenizer',
        debugShowCheckedModeBanner: false,
        theme: tokenizerTheme(),
        home: BlocListener<ModelsCubit, ModelsState>(
          listenWhen: (_, state) => !state.loading && state.error == null,
          listener: (context, state) {
            context.read<TokenizerCubit>().refreshModels(state.options);
            context.read<ComparisonCubit>().refreshModels(state.options);
            context.read<TrainingCubit>().refreshModels(state.models);
          },
          child: const _Workspace(),
        ),
      ),
    ),
  );
}

class _Workspace extends StatefulWidget {
  const _Workspace();
  @override
  State<_Workspace> createState() => _WorkspaceState();
}

class _WorkspaceState extends State<_Workspace> {
  int _selected = 0;
  void _create() => setState(() => _selected = 1);
  void _useModel(ModelOption model) {
    context.read<TokenizerCubit>().select(model);
    setState(() => _selected = 0);
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final desktop = constraints.maxWidth >= 800;
      final pages = IndexedStack(
        index: _selected,
        children: [
          TokenizerPage(onCreate: _create),
          TrainingPage(onUseModel: _useModel, active: _selected == 1),
          ModelsPage(onCreate: _create, onUseModel: _useModel),
          const ComparisonPage(),
        ],
      );
      return Scaffold(
        appBar: desktop
            ? null
            : AppBar(
                title: const Text(
                  'Flutter Tokenizer',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
                ),
              ),
        body: SafeArea(
          child: Row(
            children: [
              if (desktop && (_selected == 3 || constraints.maxHeight < 700))
                NavigationRail(
                  selectedIndex: _selected,
                  onDestinationSelected: (index) =>
                      setState(() => _selected = index),
                  labelType: NavigationRailLabelType.none,
                  destinations: const [
                    NavigationRailDestination(
                      icon: Tooltip(
                        message: 'Tokenizer',
                        child: Icon(Icons.bolt),
                      ),
                      label: Text('Tokenizer'),
                    ),
                    NavigationRailDestination(
                      icon: Tooltip(
                        message: 'Train a model',
                        child: Icon(Icons.add_circle_outline),
                      ),
                      label: Text('Train'),
                    ),
                    NavigationRailDestination(
                      icon: Tooltip(
                        message: 'Models',
                        child: Icon(Icons.inventory_2_outlined),
                      ),
                      label: Text('Models'),
                    ),
                    NavigationRailDestination(
                      icon: Tooltip(
                        message: 'Compare',
                        child: Icon(Icons.compare_arrows),
                      ),
                      label: Text('Compare'),
                    ),
                  ],
                )
              else if (desktop)
                Container(
                  width: 224,
                  color: const Color(0xff202033),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 32, 20, 8),
                        child: Icon(
                          Icons.data_array,
                          color: Color(0xffbfb0ff),
                          size: 32,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 8, 16, 4),
                        child: Text(
                          'flutter_tokenizer',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 0, 16, 36),
                        child: Text(
                          'A little language laboratory',
                          style: TextStyle(
                            color: Color(0xffaaa8bf),
                            fontSize: 12,
                          ),
                        ),
                      ),
                      for (final (index, icon, label) in [
                        (0, Icons.bolt, 'Tokenizer'),
                        (1, Icons.add_circle_outline, 'Train a model'),
                        (2, Icons.inventory_2_outlined, 'Models'),
                        (3, Icons.compare_arrows, 'Compare'),
                      ])
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              selected: _selected == index,
                              selectedTileColor: const Color(0xff39334f),
                              selectedColor: const Color(0xffd3c7ff),
                              iconColor: const Color(0xffaaa8bf),
                              textColor: const Color(0xffcccada),
                              leading: Icon(icon, size: 21),
                              title: Text(
                                label,
                                style: const TextStyle(fontSize: 14),
                              ),
                              onTap: () => setState(() => _selected = index),
                            ),
                          ),
                        ),
                      const Spacer(),
                      BlocBuilder<TrainingCubit, TrainingState>(
                        builder: (context, state) => state.busy
                            ? Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Training in progress',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    LinearProgressIndicator(
                                      value:
                                          state.phase == TrainingPhase.training
                                          ? state.progress.fraction
                                          : null,
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                      const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'POWERED BY\ndart_tokenizer\n\nLocal models. Your data.',
                          style: TextStyle(
                            color: Color(0xffaaa8bf),
                            fontSize: 11,
                            height: 1.7,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: _selected == 3 ? double.infinity : 1400,
                    ),
                    child: pages,
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: desktop
            ? null
            : NavigationBar(
                selectedIndex: _selected,
                onDestinationSelected: (index) =>
                    setState(() => _selected = index),
                destinations: const [
                  NavigationDestination(
                    icon: Icon(Icons.bolt),
                    label: 'Tokenizer',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.add_circle_outline),
                    label: 'Train',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.inventory_2_outlined),
                    label: 'Models',
                  ),
                  NavigationDestination(
                    icon: Icon(Icons.compare_arrows),
                    label: 'Compare',
                  ),
                ],
              ),
      );
    },
  );
}
