import '../../models/node.dart';
import '../path_utils.dart';
import 'file_export_unsupported.dart'
    if (dart.library.io) 'file_export_io.dart'
    if (dart.library.html) 'file_export_web.dart';

/// Export the current tree.
///
/// On native: creates folders/files directly under [baseNameOrPath].
/// On web: downloads a ZIP named after [baseNameOrPath].
Future<String> exportTree({
  required List<Node> roots,
  required String baseNameOrPath,
}) async {
  final cleaned = sanitizeNodeName(baseNameOrPath);
  return platformExportTree(
    roots: roots,
    baseNameOrPath: cleaned,
  );
}
