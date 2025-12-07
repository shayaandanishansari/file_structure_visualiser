import '../../models/node.dart';

Future<String> platformExportTree({
  required List<Node> roots,
  required String baseNameOrPath,
}) async {
  throw UnsupportedError('File export is not supported on this platform.');
}
