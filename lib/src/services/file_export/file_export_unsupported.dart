import '../../models/node.dart';
import 'file_export.dart';

class UnsupportedFileExporter implements FileExporter {
  @override
  String get defaultDisplayPath => 'Export not supported on this platform';

  @override
  Future<ExportResult> exportZip(List<Node> roots) async {
    return const ExportResult(
      success: false,
      message: 'Export is not supported on this platform.',
    );
  }
}

FileExporter createFileExporter() => UnsupportedFileExporter();
