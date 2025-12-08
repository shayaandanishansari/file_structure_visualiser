// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

import 'package:archive/archive.dart';

import '../../models/node.dart';
import '../path_utils.dart';
import 'file_export.dart';

class WebFileExporter implements FileExporter {
  @override
  String get defaultDisplayPath => 'Browser download';

  @override
  Future<ExportResult> exportZip(List<Node> roots) async {
    try {
      final bytes = _buildZipBytes(roots);
      final filename = _zipName();

      final blob = html.Blob([Uint8List.fromList(bytes)]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);

      return ExportResult(
        success: true,
        message: 'ZIP downloaded: $filename',
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'Web ZIP export failed: $e',
      );
    }
  }

  String _zipName() {
    final ts = DateTime.now()
        .toIso8601String()
        .replaceAll(':', '')
        .replaceAll('.', '')
        .replaceAll('-', '');
    return 'file_structure_$ts.zip';
  }

  List<int> _buildZipBytes(List<Node> roots) {
    final archive = Archive();

    void walk(Node n, String prefix) {
      final safe = PathUtils.sanitizeComponent(n.name);
      final path = prefix.isEmpty ? safe : '${prefix}_$safe';

      if (n.isFolder || n.children.isNotEmpty) {
        // Add a directory marker (not strictly required, but nice)
        archive.addFile(ArchiveFile('$path/', 0, const <int>[]));
        for (final c in n.children) {
          walk(c, path);
        }
      } else {
        archive.addFile(ArchiveFile(path, 0, const <int>[]));
      }
    }

    for (final r in roots) {
      walk(r, '');
    }

    return ZipEncoder().encode(archive) ?? <int>[];
  }
}

FileExporter createFileExporter() => WebFileExporter();
