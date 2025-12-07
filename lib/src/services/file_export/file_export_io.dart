import 'dart:io';

import '../../models/node.dart';
import '../path_utils.dart';

Future<String> platformExportTree({
  required List<Node> roots,
  required String baseNameOrPath,
}) async {
  // Treat as absolute or user-chosen directory.
  final dir = Directory(baseNameOrPath);
  if (!dir.existsSync()) {
    dir.createSync(recursive: true);
  }

  for (final root in roots) {
    _writeNode(root, dir.path);
  }

  // Try to open the folder on desktop platforms.
  if (Platform.isWindows) {
    try {
      await Process.run('explorer.exe', [dir.path]);
    } catch (_) {}
  } else if (Platform.isMacOS) {
    try {
      await Process.run('open', [dir.path]);
    } catch (_) {}
  } else if (Platform.isLinux) {
    try {
      await Process.run('xdg-open', [dir.path]);
    } catch (_) {}
  }

  return 'Created structure at ${dir.path}';
}

void _writeNode(Node node, String currentPath) {
  final safe = sanitizeFileComponent(node.name);
  final here = '$currentPath${Platform.pathSeparator}$safe';

  if (node.children.isNotEmpty || node.isFolder) {
    final dir = Directory(here);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    for (final child in node.children) {
      _writeNode(child, here);
    }
  } else {
    final file = File(here);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
  }
}
