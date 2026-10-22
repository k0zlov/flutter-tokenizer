import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'app.dart';
import 'core/data/app_database.dart';
import 'core/data/dart_tokenizer_engine.dart';
import 'features/models/data/local_model_repository.dart';
import 'features/training/data/local_corpus_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const _Bootstrap());
}

class _Bootstrap extends StatefulWidget {
  const _Bootstrap();
  @override
  State<_Bootstrap> createState() => _BootstrapState();
}

class _BootstrapState extends State<_Bootstrap> {
  AppDatabase? _database;
  LocalModelRepository? _repository;
  bool _failed = false;
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    setState(() => _failed = false);
    try {
      final support = await getApplicationSupportDirectory();
      await support.create(recursive: true);
      final database = AppDatabase(
        NativeDatabase.createInBackground(
          File(p.join(support.path, 'tokenizer.sqlite')),
        ),
      );
      _database = database;
      final repository = LocalModelRepository(
        database,
        Directory(p.join(support.path, 'models')),
      );
      await repository.recoverInterruptedSaves();
      if (mounted) setState(() => _repository = repository);
    } catch (_) {
      await _database?.close();
      _database = null;
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void dispose() {
    _database?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_repository != null) {
      return TokenizerApp(
        repository: _repository!,
        engine: const DartTokenizerEngine(),
        picker: const LocalCorpusPicker(),
      );
    }
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: tokenizerTheme(),
      home: Scaffold(
        body: Center(
          child: _failed
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.folder_off_outlined, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Could not open local storage. Check available disk space and try again.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: _initialize,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
