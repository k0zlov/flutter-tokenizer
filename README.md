# Flutter Tokenizer

An English-language, local-first BPE laboratory for desktop and mobile. Train on your own UTF-8 text files, tokenize text, and inspect vocabulary and ranked merge rules with readable text, decimal bytes, and hex.

## Run

Requires Flutter with Dart **3.13.3 or newer** and the existing package beside this project:

```text
IdeaProjects/
  dart_tokenizer/
  flutter_tokenizer/
```

```sh
flutter pub get
dart run build_runner build
flutter run -d macos
```

Use an Android emulator/device or iOS simulator/device with `flutter run -d <device-id>`. Linux and Windows need their platform toolchains. This MVP uses native local storage and Dart isolates; **web is not supported**. macOS file-picker sandbox entitlements are included. Android SDK licenses must be accepted on this machine before Android builds (`flutter doctor --android-licenses`).

`pubspec.yaml` points to `../dart_tokenizer`. Replace that dependency with your package's Git URL/ref or published version when needed. No tokenizer algorithm is copied into this app.

## Built-in tiktoken models

All `TiktokenModel.values` presets and `TiktokenEncoding.values` encodings from the local package are always listed in Models and in the tokenizer selector, including before custom models load or when loading them fails. They are runtime catalog entries, never database rows or local model files, and cannot be deleted. Only custom BPE models have an inspection page.

Built-ins delegate to `TiktokenTokenizer.fromModel` / `fromEncoding` and `TokenizerEvaluator`. They show token IDs, vocabulary size, metrics, full decoded text, and round-trip status. The current package wrapper does not expose lossless per-token bytes, so byte/vocabulary/merge inspection remains specific to custom models.

## Managing custom models

Open **Model actions** (the three-dot menu) on a custom model card or its details page to **Rename model** or **Delete model**. Names are trimmed and must contain 1–80 characters. Renaming updates the library display name in Drift and every model selector; the trained tokenizer artifact, its original training name, IDs, vocabulary, and merge rules remain unchanged.

Deletion asks for confirmation and removes the tokenizer file, model metadata, and source metadata. Original corpus files are kept. A deleted selection falls back to an available model and clears its obsolete results in Tokenizer and Compare. Built-in tiktoken entries have neither action.

Deletion stages the model file before the database transaction. Failed transactions restore it; startup restores interrupted uncommitted deletions or finishes file cleanup after a committed deletion. No schema migration is required.

## Demo

1. Open **Train a model**, enter a name, and add one or both files from `example_corpus/`. On macOS, Windows, and Linux, drag files onto the corpus card or use **Add text files**. Mobile uses the file picker. Both paths validate UTF-8, file types, and the combined size; duplicate contents are included once. Folders are rejected, and adding files is disabled during training.
2. Choose a target vocabulary (try 512), then **Train & save model**. Progress comes directly from the package's `TokenizerProgress` callback. Training runs in a worker isolate and can be cancelled before saving.
3. Choose **Use this model**, enter text, and tokenize. Inspect colored token pieces, all token IDs, decoded text, exact round-trip status, and package evaluation metrics.
4. Open **Models → Inspect model** to inspect training metadata, corpus fingerprints, vocabulary, and merge rules. Search IDs, ranks, readable text, decimal bytes, or hex. UTF-8 filters distinguish valid text from byte fragments.

5. Open **Compare**, select any two custom or built-in models, enter shared text, and choose **Compare models**. Wide windows show two independently scrollable result panels with pinned model selectors; narrow or short windows stack the panels. The input collapses after comparison to leave more room for results; use **Edit shared input** to reopen it. **Swap A / B** keeps each model with its result. Each side shows its own errors without hiding a successful result on the other side.

Vocabulary size includes all 256 base byte tokens. Training may stop below the requested size when no pair meets the minimum frequency. Embedding dimensions and Float16/Float32 precision are **estimates only**; BPE does not learn embedding weights. Estimated matrix memory is vocabulary × dimensions × bytes per weight, without optimizer state or other layers. **Weight precision** means the numeric format of each hypothetical embedding weight: Float16 uses 2 bytes, Float32 uses 4 bytes. For 16,384 tokens and 256 dimensions, that is 8 MiB versus 16 MiB. This setting changes only the memory estimate and saved metadata; it does not change BPE training, token IDs, or tokenizer-file size.

For a training experiment, reserve separate documents as held-out text and compare vocabulary sizes (for example 4k, 8k, 16k) with the same corpus and minimum pair frequency. Evaluate English and Ukrainian separately. Token count measures segmentation efficiency, not downstream language-model quality. Single-run encoding timings are observations, not a controlled benchmark.

## Architecture

```text
lib/
  app.dart                       Composition and responsive navigation
  core/
    domain/                      Plain Dart values and TokenizerEngine interface
    data/                        dart_tokenizer adapter; Drift schema/generated code
    presentation/                Shared widgets and display formatting
  features/
    tokenizer/
      application/               Shared tokenization use case
      presentation/              Tokenizer Cubit, input, and results
    comparison/presentation/     Shared input, two-model Cubit and result panels
    training/
      domain/                    CorpusPicker interface
      application/               TrainModel orchestration: train, then persist
      data/                      Native file picker, UTF-8 validation, fingerprints
      presentation/              Training Cubit, configuration, progress
    models/
      domain/                    ModelRepository interface
      data/                      Drift metadata + model-file repository
      presentation/              Library and inspection Cubits/screens
```

Domain and application code import no Flutter, Drift, or file-system APIs. Cubits live in presentation and depend on interfaces. Infrastructure is injected at startup; tests substitute interfaces where appropriate.

The adapter delegates training to **BpeTrainer.train**, encoding/decoding/loading to **BpeTokenizer**, metrics to **TokenizerEvaluator**, and vocabulary/merge translation to **BpeTokenizerTranslator** (the actual translator name in the local package). JSON serialization uses the package's `toJson`; model files can be loaded directly with `BpeTokenizer.load`. No BPE training or merge algorithm is reimplemented. Metrics use a separate package evaluation pass, so evaluation throughput and the displayed encoding duration measure separate runs.

## Persistence and limits

- Application support directory: `tokenizer.sqlite` for metadata and ordered source records; `models/model_<id>.json` for package-compatible models. The model details page shows the resolved path.
- Model names, creation time, actual/target vocabulary, corpus bytes/Unicode characters, training duration, frequency, embedding estimates, file size, and source names/line counts/SHA-256 fingerprints are persisted.
- Files are joined in picker order with one newline. Corpus totals include separators. Identical file contents are deduplicated. Original source contents are not copied to persistent storage; trained tokens can still contain corpus text.
- A temporary file is flushed and renamed before an atomic metadata transaction. Failed saves remove their file. Startup cleans unreferenced model files and interrupted temporary saves. Only successfully saved models appear in the library.
- MVP bounds: 20 MiB combined corpus, 256–32,768 target vocabulary, 100,000 input UTF-16 code units. The package trainer holds the corpus in memory; large corpora and vocabularies can take time. Inspection and token display use pagination.
- Standalone byte fragments are not forced into malformed replacement text. Their exact bytes remain visible; complete sequences are decoded by the package.

## Development and verification

```sh
dart run build_runner build       # Regenerate after Drift schema changes
dart format lib test
flutter analyze
flutter test
flutter build macos --debug
```

Tests exercise actual package training, package-compatible save/reload, SQLite persistence across restart, Unicode and empty round trips, partial UTF-8 tokens, cancellation, failed-save rollback, recovery, desktop drop validation and access-bookmark cleanup, independent comparison failures and stale-result protection, and mobile/desktop/short-window UI flows. Schema version is 1; introduce a migration when changing a shipped database schema.
