import '../../models/node.dart';
import 'file_export.dart';

class FileExportUnsupported implements FileExportService {
  @override
  String get defaultLocationDisplay => 'Export not supported on this platform';

  @override
  Future<String> exportZip(List<Node> roots) async {
    throw UnimplementedError(
      'ZIP export is not supported on this platform build.',
    );
  }
}

FileExportService createFileExportServiceImpl() => FileExportUnsupported();
