import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tokenizer/app.dart';
import 'package:flutter_tokenizer/core/domain/tokenizer_entities.dart';
import 'package:flutter_tokenizer/features/comparison/presentation/comparison_page.dart';

import 'support/fakes.dart';

const builtIns = [
  BuiltInModel(name: 'gpt-4', encoding: 'cl100k_base', kind: BuiltInKind.model),
  BuiltInModel(name: 'gpt2', encoding: 'gpt2', kind: BuiltInKind.encoding),
];

class ComparisonFixtureEngine extends StubEngine {
  ComparisonFixtureEngine() : super(builtInModels: builtIns);
  @override
  Future<TokenizationResult> tokenizeBuiltIn(
    BuiltInModel model,
    String text,
  ) async => TokenizationResult(
    ids: const [12, 34, 56],
    pieces: const [],
    supportsTokenDetails: false,
    decoded: text,
    roundTrip: true,
    metrics: const {'Bytes / token': 2, 'Tokens / word': 3},
    elapsedMicroseconds: 1000,
  );
}

void main() {
  for (final size in [
    const Size(390, 844),
    const Size(1200, 820),
    const Size(1000, 600),
  ]) {
    testWidgets(
      'comparison has usable space and supports custom plus built-in models at $size',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final repository = MemoryRepository(models: [model]);
        addTearDown(repository.changes.close);
        await tester.pumpWidget(
          TokenizerApp(
            repository: repository,
            engine: ComparisonFixtureEngine(),
            picker: StubPicker(),
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.compare_arrows).last);
        await tester.pumpAndSettle();
        final a = find.byKey(const ValueKey('comparison-A'));
        final b = find.byKey(const ValueKey('comparison-B'));
        if (size.width >= 1100 && size.height >= 650) {
          expect(tester.getRect(a).right, lessThan(tester.getRect(b).left));
          expect(tester.getSize(a).width, greaterThan(450));
        }
        await tester.enterText(
          find.byKey(const ValueKey('comparison-input')),
          'A',
        );
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
        final selectorA = find.widgetWithText(
          DropdownButtonFormField<String>,
          'Model A',
        );
        if (size.width < 1100 || size.height < 650) {
          await tester.scrollUntilVisible(
            selectorA.hitTestable(),
            200,
            scrollable: find
                .descendant(
                  of: find.byType(ComparisonPage),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
        }
        await tester.tap(selectorA);
        await tester.pumpAndSettle();
        await tester.tap(find.text(model.selectionLabel).last);
        await tester.pumpAndSettle();
        final compare = find.text('Compare models');
        if (!compare.hitTestable().evaluate().isNotEmpty) {
          await tester.scrollUntilVisible(
            compare.hitTestable(),
            -200,
            scrollable: find
                .descendant(
                  of: find.byType(ComparisonPage),
                  matching: find.byType(Scrollable),
                )
                .first,
          );
        }
        await tester.tap(compare);
        await tester.pumpAndSettle();
        expect(find.byKey(const ValueKey('comparison-input')), findsNothing);
        expect(
          find.textContaining('Model A uses 2 fewer tokens'),
          findsOneWidget,
        );
        if (size.width >= 1100 && size.height >= 650) {
          expect(find.text('Match ✓'), findsNWidgets(2));
          expect(find.text('#12'), findsOneWidget);
          expect(tester.getSize(a).height, greaterThan(400));
          await tester.tap(find.text('Swap A / B'));
          await tester.pumpAndSettle();
          expect(
            find.textContaining('Model B uses 2 fewer tokens'),
            findsOneWidget,
          );
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
}
