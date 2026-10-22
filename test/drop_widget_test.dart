import 'dart:io';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tokenizer/app.dart';
import 'package:flutter_tokenizer/features/training/application/train_model.dart';
import 'package:flutter_tokenizer/features/training/data/local_corpus_picker.dart';
import 'package:flutter_tokenizer/features/training/presentation/training_cubit.dart';
import 'package:flutter_tokenizer/features/training/presentation/widgets/corpus_card.dart';

import 'support/fakes.dart';

void main() {
  testWidgets(
    'desktop drop highlights and imports real files into the corpus',
    (tester) async {
      final directory = Directory.systemTemp.createTempSync('drop_widget_');
      addTearDown(() => directory.deleteSync(recursive: true));
      final file = File('${directory.path}/hello.txt')
        ..writeAsStringSync('Hello 👋');
      final repository = MemoryRepository();
      addTearDown(repository.changes.close);
      final cubit = TrainingCubit(
        const LocalCorpusPicker(),
        TrainModel(StubEngine(), repository),
      );
      addTearDown(cubit.close);
      await tester.pumpWidget(
        MaterialApp(
          theme: tokenizerTheme(),
          home: Scaffold(
            body: BlocBuilder<TrainingCubit, TrainingState>(
              bloc: cubit,
              builder: (context, state) => SingleChildScrollView(
                child: CorpusCard(
                  state: state,
                  onAdd: cubit.addFiles,
                  onRemove: cubit.removeFile,
                  onDrop: cubit.addDroppedFiles,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      var target = tester.widget<DropTarget>(find.byType(DropTarget));
      expect(target.enable, isTrue);
      target.onDragEntered!(
        DropEventDetails(
          localPosition: Offset.zero,
          globalPosition: Offset.zero,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Release to add your files'), findsOneWidget);
      target = tester.widget<DropTarget>(find.byType(DropTarget));
      await tester.runAsync(() async {
        target.onDragDone!(
          DropDoneDetails(
            files: [DropItemFile(file.path)],
            localPosition: Offset.zero,
            globalPosition: Offset.zero,
          ),
        );
        await cubit.stream
            .firstWhere((state) => !state.busy)
            .timeout(const Duration(seconds: 10));
      });
      await tester.pumpAndSettle();
      expect(cubit.state.error, isNull);
      expect(cubit.state.documents.single.text, 'Hello 👋');
      expect(find.text('hello.txt'), findsOneWidget);
      expect(find.text('Release to add your files'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );
  testWidgets(
    'drop target ignores files during training and while its tab is hidden',
    (tester) async {
      var imports = 0;
      for (final active in [true, false]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: CorpusCard(
                  active: active,
                  state: active
                      ? const TrainingState(phase: TrainingPhase.training)
                      : const TrainingState(),
                  onAdd: () {},
                  onRemove: (_) {},
                  onDrop: (_) => imports++,
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();
        final target = tester.widget<DropTarget>(find.byType(DropTarget));
        expect(target.enable, isFalse);
        target.onDragDone!(
          const DropDoneDetails(
            files: [],
            localPosition: Offset.zero,
            globalPosition: Offset.zero,
          ),
        );
        await tester.pumpAndSettle();
        expect(imports, 0);
      }
      await tester.pumpWidget(const SizedBox());
    },
    variant: TargetPlatformVariant({TargetPlatform.macOS}),
  );
}
