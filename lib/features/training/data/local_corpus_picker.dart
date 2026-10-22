import 'dart:convert';
import 'dart:isolate';
import 'dart:io';
import 'dart:typed_data';

import 'package:desktop_drop/desktop_drop.dart';

import 'package:path/path.dart' as p;

import 'package:crypto/crypto.dart';
import 'package:file_selector/file_selector.dart';

import '../../../core/domain/tokenizer_entities.dart';
import '../domain/corpus_picker.dart';

class LocalCorpusPicker implements CorpusPicker {
  const LocalCorpusPicker();
  @override
  Future<List<CorpusDocument>> pick() async {
    final files = await openFiles(
      acceptedTypeGroups: [
        const XTypeGroup(
          label: 'UTF-8 text files',
          extensions: ['txt', 'md', 'csv', 'text'],
          uniformTypeIdentifiers: [
            'public.plain-text',
            'public.comma-separated-values-text',
          ],
        ),
      ],
    );
    return _readFiles(files);
  }

  @override
  Future<List<CorpusDocument>> readDroppedFiles(
    List<CorpusFileReference> files,
  ) async {
    final accessed = <Uint8List>[];
    try {
      for (final reference in files) {
        final bookmark = reference.accessBookmark;
        if (Platform.isMacOS && bookmark != null && bookmark.isNotEmpty) {
          final bytes = Uint8List.fromList(bookmark);
          if (await DesktopDrop.instance.startAccessingSecurityScopedResource(
            bookmark: bytes,
          )) {
            accessed.add(bytes);
          }
        }
        if (await FileSystemEntity.type(reference.path) !=
            FileSystemEntityType.file) {
          throw const AppFailure(
            'Drop text files only. Folders and unavailable files cannot be added.',
          );
        }
      }
      return await _readFiles(files.map((file) => XFile(file.path)).toList());
    } on AppFailure {
      rethrow;
    } catch (_) {
      throw const AppFailure(
        'Could not access the dropped files. Try adding them with the file picker.',
      );
    } finally {
      for (final bookmark in accessed.reversed) {
        await DesktopDrop.instance.stopAccessingSecurityScopedResource(
          bookmark: bookmark,
        );
      }
    }
  }

  Future<List<CorpusDocument>> _readFiles(List<XFile> files) async {
    final documents = <CorpusDocument>[];
    var total = 0;
    for (final file in files) {
      if (![
        '.txt',
        '.md',
        '.csv',
        '.text',
      ].contains(p.extension(file.name).toLowerCase())) {
        throw AppFailure(
          '“${file.name}” is not supported. Add .txt, .md, .csv, or .text files.',
        );
      }
      total += await file.length();
      if (total > 20 * 1024 * 1024) {
        throw const AppFailure(
          'Choose up to 20 MiB of text files for this demo.',
        );
      }
      final List<int> bytes;
      try {
        bytes = await file.readAsBytes();
      } on FileSystemException {
        throw AppFailure(
          'Could not read “${file.name}”. Try adding it with the file picker.',
        );
      }
      if (bytes.length > 20 * 1024 * 1024) {
        throw const AppFailure(
          'Choose up to 20 MiB of text files for this demo.',
        );
      }
      final name = file.name;
      final document = await Isolate.run(() {
        try {
          final text = utf8.decode(bytes, allowMalformed: false);
          if (text.contains('\u0000')) {
            throw const FormatException('Binary content');
          }
          return CorpusDocument(
            CorpusSource(
              name: name,
              bytes: bytes.length,
              characters: text.runes.length,
              lines: const LineSplitter().convert(text).length,
              sha256: sha256.convert(bytes).toString(),
            ),
            text,
          );
        } on FormatException {
          throw AppFailure('“$name” is not a supported UTF-8 text file.');
        }
      });
      documents.add(document);
    }
    return documents;
  }
}
