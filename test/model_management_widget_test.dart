import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tokenizer/app.dart';
import 'package:flutter_tokenizer/core/domain/tokenizer_entities.dart';
import 'package:flutter_tokenizer/features/comparison/presentation/comparison_cubit.dart';
import 'package:flutter_tokenizer/features/models/presentation/models_page.dart';
import 'package:flutter_tokenizer/features/models/presentation/model_details_page.dart';
import 'package:flutter_tokenizer/features/tokenizer/presentation/tokenizer_page.dart';
import 'package:flutter_tokenizer/features/tokenizer/presentation/tokenizer_cubit.dart';

import 'support/fakes.dart';

const builtin = BuiltInModel(
  name: 'gpt-4',
  encoding: 'cl100k_base',
  kind: BuiltInKind.model,
);

class FailingManagementRepository extends MemoryRepository {
  FailingManagementRepository() : super(models: [model]);
  @override
  Future<void> delete(SavedModel model) async =>
      throw const AppFailure('Could not delete the model. Please try again.');
}

void main() {
  for (final size in [const Size(390, 844), const Size(1440, 1000)]) {
    testWidgets('rename and delete selected model at $size', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = MemoryRepository(models: [model]);
      addTearDown(repository.changes.close);
      await tester.pumpWidget(
        TokenizerApp(
          repository: repository,
          engine: StubEngine(builtInModels: const [builtin]),
          picker: StubPicker(),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(TokenizerPage));
      final tokenizer = context.read<TokenizerCubit>();
      final comparison = context.read<ComparisonCubit>();
      tokenizer.select(model);
      comparison.select(true, model);
      await tokenizer.tokenize('A');
      await comparison.compare();
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.inventory_2_outlined).last);
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.byTooltip('Model actions'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ModelsPage),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.byTooltip('Model actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Rename model'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Model name'),
        '   ',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(
        find.text('Enter a model name between 1 and 80 characters.'),
        findsOneWidget,
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Model name'),
        'Renamed model',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(repository.models.single.name, 'Renamed model');
      expect(tokenizer.state.model!.name, 'Renamed model');
      expect(comparison.state.left.model!.name, 'Renamed model');
      expect(tokenizer.state.result, isNotNull);
      expect(comparison.state.left.result, isNotNull);
      await tester.scrollUntilVisible(
        find.text('Inspect model'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ModelsPage),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.tap(find.text('Inspect model'));
      await tester.pumpAndSettle();
      expect(find.byType(ModelDetailsPage), findsOneWidget);
      await tester.tap(find.byTooltip('Model actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete model'));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Renamed model', findRichText: true),
        findsWidgets,
      );
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(repository.models, hasLength(1));
      await tester.tap(find.byTooltip('Model actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete model'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(repository.models, isEmpty);
      expect(find.byType(ModelDetailsPage), findsNothing);
      expect(tokenizer.state.model!.id, builtin.id);
      expect(tokenizer.state.result, isNull);
      expect(comparison.state.left.model!.id, builtin.id);
      expect(comparison.state.left.result, isNull);
      expect(comparison.state.right.result, isNotNull);
      expect(find.byTooltip('Model actions'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'failed deletion stays open with actionable error and preserves model',
    (tester) async {
      final repository = FailingManagementRepository();
      addTearDown(repository.changes.close);
      await tester.pumpWidget(
        TokenizerApp(
          repository: repository,
          engine: StubEngine(),
          picker: StubPicker(),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.inventory_2_outlined).last);
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Model actions'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete model'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(
        find.text('Could not delete the model. Please try again.'),
        findsOneWidget,
      );
      expect(repository.models, hasLength(1));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
