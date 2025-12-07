import 'dart:html' as html;
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../models/node.dart';
import '../path_utils.dart';

Future<String> platformExportTree({
  required List<Node> roots,
  required String baseNameOrPath,
}) async {
  final archive = Archive();

  final rootDirName = sanitizeFileComponent(
    baseNameOrPath.isEmpty ? 'project' : baseNameOrPath,
  );

  if (roots.isEmpty) {
    // Always have at least one directory in the ZIP.
    final keepPath = '$rootDirName/.keep';
    archive.addFile(ArchiveFile(keepPath, 0, Uint8List(0)));
  } else {
    for (final root in roots) {
      _addNode(
        archive: archive,
        node: root,
        parentPath: rootDirName,
      );
    }
  }

  final zipData = ZipEncoder().encode(archive);
  if (zipData == null) {
    throw Exception('Failed to create ZIP archive.');
  }

  final bytes = Uint8List.fromList(zipData);
  final blob = html.Blob([bytes], 'application/zip');
  final url = html.Url.createObjectUrlFromBlob(blob);

  final anchor = html.AnchorElement(href: url)
    ..style.display = 'none'
    ..download = '$rootDirName.zip';
  html.document.body!.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);

  return 'Downloaded ZIP: $rootDirName.zip';
}

void _addNode({
  required Archive archive,
  required Node node,
  required String parentPath,
}) {
  final safeName = sanitizeFileComponent(node.name);
  final currentPath = '$parentPath/$safeName';

  if (node.children.isNotEmpty || node.isFolder) {
    if (node.children.isEmpty) {
      // Represent empty folders with a .keep file so they exist after unzip.
      final keepPath = '$currentPath/.keep';
      archive.addFile(ArchiveFile(keepPath, 0, Uint8List(0)));
    } else {
      for (final child in node.children) {
        _addNode(
          archive: archive,
          node: child,
          parentPath: currentPath,
        );
      }
    }
  } else {
    archive.addFile(ArchiveFile(currentPath, 0, Uint8List(0)));
  }
}
