import '../../models/node.dart';

import 'file_export_unsupported.dart'
    if (dart.library.io) 'file_export_io.dart'
    if (dart.library.html) 'file_export_web.dart';

/// Result returned to the UI so you can show clean toasts.
class ExportResult {
  final bool success;
  final String message;
  final String? savedPath;

  const ExportResult({
    required this.success,
    required this.message,
    this.savedPath,
  });
}

/// Platform-agnostic exporter interface.
/// v1 rule: ALWAYS export a ZIP. Never create real folders/files.
abstract class FileExporter {
  /// Human-friendly path string for the UI display box.
  String get defaultDisplayPath;

  /// Exports the given roots as a ZIP using platform rules:
  /// - Web: triggers browser download
  /// - IO: saves zip to default safe directory
  Future<ExportResult> exportZip(List<Node> roots);
}

/// Factory provided by the conditional import implementation.
FileExporter createFileExporter() => throw UnimplementedError();
