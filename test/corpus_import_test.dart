import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_tokenizer/core/domain/tokenizer_entities.dart';
import 'package:flutter_tokenizer/features/training/application/train_model.dart';
import 'package:flutter_tokenizer/features/training/data/local_corpus_picker.dart';
import 'package:flutter_tokenizer/features/training/domain/corpus_picker.dart';
import 'package:flutter_tokenizer/features/training/presentation/training_cubit.dart';

import 'support/fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const picker = LocalCorpusPicker();
  late Directory folder;
  late MemoryRepository repository;
  late TrainingCubit cubit;
  setUp(() async {
    folder = await Directory.systemTemp.createTemp('corpus_drop_');
    repository = MemoryRepository();
    cubit = TrainingCubit(picker, TrainModel(StubEngine(), repository));
  });
  tearDown(() async {
    await cubit.close();
    await repository.changes.close();
    await folder.delete(recursive: true);
  });
  Future<CorpusFileReference> file(String name, String text) async {
    final f = await File('${folder.path}/$name').writeAsString(text);
    return CorpusFileReference(f.path);
  }

  test('dropped files preserve Unicode statistics and deduplicate with the existing corpus', () async {
    final a = await file('ukr.TXT', 'Привіт 👋\nСвіт');
    final b = await file('english.md', 'Hello world');
    await cubit.addDroppedFiles([a, b]);
    expect(cubit.state.error, isNull);
    expect(cubit.state.documents.map((d) => d.source.name), [
      'ukr.TXT',
      'english.md',
    ]);
    final source = cubit.state.documents.first.source;
    expect(source.bytes, utf8.encode('Привіт 👋\nСвіт').length);
    expect(source.characters, 'Привіт 👋\nСвіт'.runes.length);
    expect(source.lines, 2);
    expect(source.sha256.length, 64);
    await cubit.addDroppedFiles([await file('duplicate.txt', 'Hello world')]);
    expect(cubit.state.documents.length, 2);
  });
  test('invalid batch, directories, and oversized files preserve the previous corpus', () async {
    await cubit.addDroppedFiles([await file('valid.txt', 'keep me')]);
    final invalid = File('${folder.path}/invalid.txt');
    await invalid.writeAsBytes([255, 254, 0]);
    await cubit.addDroppedFiles([
      await file('new.txt', 'new'),
      CorpusFileReference(invalid.path),
    ]);
    expect(cubit.state.documents.single.text, 'keep me');
    expect(cubit.state.error, contains('UTF-8'));
    await cubit.addDroppedFiles([CorpusFileReference(folder.path)]);
    expect(cubit.state.error, contains('Folders'));
    expect(cubit.state.documents.length, 1);
    await cubit.addDroppedFiles([await file('image.png', 'not a text file')]);
    expect(cubit.state.error, contains('not supported'));
    final large = await File('${folder.path}/large.txt')
        .open(mode: FileMode.write);
    await large.truncate(20 * 1024 * 1024 + 1);
    await large.close();
    await cubit.addDroppedFiles([
      CorpusFileReference('${folder.path}/large.txt'),
    ]);
    expect(cubit.state.error, contains('20 MiB'));
    expect(cubit.state.documents.length, 1);
  });
  test(
    'macOS drop bookmarks are released even when UTF-8 validation fails',
    () async {
      final calls = <String>[];
      const channel = MethodChannel('desktop_drop');
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call.method);
            return true;
          });
      addTearDown(
        () => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null),
      );
      final invalid = await File('${folder.path}/bad.txt').writeAsBytes([255]);
      await expectLater(
        picker.readDroppedFiles([
          CorpusFileReference(invalid.path, accessBookmark: [1, 2]),
        ]),
        throwsA(isA<AppFailure>()),
      );
      expect(calls, [
        'startAccessingSecurityScopedResource',
        'stopAccessingSecurityScopedResource',
      ]);
    },
    skip: !Platform.isMacOS,
  );
}
