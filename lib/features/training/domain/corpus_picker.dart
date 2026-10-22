import '../../../core/domain/tokenizer_entities.dart';

abstract interface class CorpusPicker {
  Future<List<CorpusDocument>> pick();
  Future<List<CorpusDocument>> readDroppedFiles(
    List<CorpusFileReference> files,
  );
}

/// A native drop reference. The optional access token is opaque to application logic.
class CorpusFileReference {
  const CorpusFileReference(this.path, {this.accessBookmark});
  final String path;
  final List<int>? accessBookmark;
}
