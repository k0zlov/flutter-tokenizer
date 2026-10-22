import 'support/fakes.dart';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tokenizer/app.dart';
import 'package:flutter_tokenizer/core/data/dart_tokenizer_engine.dart';
import 'package:flutter_tokenizer/core/domain/tokenizer_entities.dart';
import 'package:flutter_tokenizer/features/models/presentation/entry_browser.dart';
import 'package:flutter_tokenizer/features/tokenizer/presentation/tokenizer_page.dart';
import 'package:flutter_tokenizer/features/training/presentation/training_page.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(1440, 1000)]) {
    testWidgets(
      'built-ins are selectable and have no detail/delete actions at ${size.width}px',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = MemoryRepository();
        addTearDown(repository.changes.close);
        final builtIns = const DartTokenizerEngine().builtInModels;
        await tester.pumpWidget(
          TokenizerApp(
            repository: repository,
            engine: StubEngine(builtInModels: builtIns),
            picker: StubPicker(),
          ),
        );
        await tester.pumpAndSettle();
        final selector = tester.widget<DropdownButton<String>>(
          find.byType(DropdownButton<String>),
        );
        expect(
          selector.items!.map((item) => item.value),
          builtIns.map((m) => m.id),
        );
        expect(selector.value, builtIns.first.id);
        expect(find.text('Your first model starts here'), findsNothing);
        await tester.tap(find.text('Models').last);
        await tester.pumpAndSettle();
        expect(find.text('Built-in tiktoken'), findsOneWidget);
        expect(find.text('gpt-4'), findsOneWidget);
        expect(find.text('Inspect model'), findsNothing);
        expect(find.byIcon(Icons.delete), findsNothing);
        expect(find.byIcon(Icons.delete_outline), findsNothing);
        await tester.tap(find.byTooltip('Use gpt-4'));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Text to tokenize'),
          'A',
        );
        await tester.tap(find.text('Tokenize text'));
        await tester.pumpAndSettle();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('#65').hitTestable(),
          250,
          scrollable: find
              .descendant(
                of: find.byType(TokenizerPage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        expect(find.text('#65'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }
  for (final size in [const Size(390, 844), const Size(1440, 1000)]) {
    testWidgets(
      'train, select, and tokenize through the UI at ${size.width}px',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = MemoryRepository();
        addTearDown(repository.changes.close);
        await tester.pumpWidget(
          TokenizerApp(
            repository: repository,
            engine: StubEngine(),
            picker: StubPicker(),
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Your first model starts here'), findsOneWidget);
        await tester.tap(find.text('Create a model').first);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Model name'),
          'Demo model',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        final add = find.text('Add text files');
        await tester.scrollUntilVisible(
          add.hitTestable(),
          250,
          scrollable: find
              .descendant(
                of: find.byType(TrainingPage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(add);
        await tester.pumpAndSettle();
        final train = find.text('Train & save model');
        await tester.scrollUntilVisible(
          train.hitTestable(),
          250,
          scrollable: find
              .descendant(
                of: find.byType(TrainingPage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(train);
        await tester.pumpAndSettle();
        final use = find.text('Use this model');
        await tester.scrollUntilVisible(
          use.hitTestable(),
          250,
          scrollable: find
              .descendant(
                of: find.byType(TrainingPage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(use);
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextField, 'Text to tokenize'),
          'A',
        );
        await tester.tap(find.text('Tokenize text'));
        await tester.pumpAndSettle();
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        await tester.scrollUntilVisible(
          find.text('Exact match ✓').hitTestable(),
          250,
          scrollable: find
              .descendant(
                of: find.byType(TokenizerPage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        expect(find.text('Exact match ✓'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'inspection searches decimal bytes and filters byte fragments on a small screen',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      const fragment = TokenPiece(id: 208, bytes: [208], text: null, hex: 'D0');
      await tester.pumpWidget(
        MaterialApp(
          theme: tokenizerTheme(),
          home: const Scaffold(
            body: EntryBrowser(
              data: ModelInspection([piece, fragment], []),
              showMerges: false,
            ),
          ),
        ),
      );
      await tester.enterText(find.byType(TextField), '208');
      await tester.pumpAndSettle();
      expect(find.text('ID 208'), findsOneWidget);
      expect(find.text('ID 65'), findsNothing);
      await tester.tap(find.text('Valid UTF-8'));
      await tester.pumpAndSettle();
      expect(find.text('No entries match your search.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
