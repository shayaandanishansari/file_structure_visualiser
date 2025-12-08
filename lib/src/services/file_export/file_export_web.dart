// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../models/node.dart';
import '../path_utils.dart';
import 'file_export.dart';

class FileExportWeb implements FileExportService {
  @override
  String get defaultLocationDisplay => 'Browser downloads';

  @override
  Future<String> exportZip(List<Node> roots) async {
    final bytes = _buildZipBytes(roots);
    final name = PathUtils.defaultZipFileName();

    _downloadBytes(bytes, name);
    return 'Download started';
  }

  Uint8List _buildZipBytes(List<Node> roots) {
    final archive = Archive();

    void addNode(Node n, String parentPath) {
      final safeName = PathUtils.sanitizeComponent(n.name);
      final currentPath = PathUtils.joinZip(parentPath, safeName);

      final isDirectory = n.isFolder || n.children.isNotEmpty;

      if (isDirectory) {
        // Add an explicit directory entry.
        archive.addFile(ArchiveFile('$currentPath/', 0, const []));
        for (final c in n.children) {
          addNode(c, currentPath);
        }
      } else {
        // Empty file entry.
        archive.addFile(ArchiveFile(currentPath, 0, const []));
      }
    }

    for (final r in roots) {
      addNode(r, '');
    }

    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded ?? const <int>[]);
  }

  void _downloadBytes(Uint8List bytes, String filename) {
    final blob = html.Blob([bytes], 'application/zip');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..download = filename
      ..style.display = 'none';

    html.document.body?.children.add(anchor);
    anchor.click();
    anchor.remove();
    html.Url.revokeObjectUrl(url);
  }
}

FileExportService createFileExportServiceImpl() => FileExportWeb();
