import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../models/node.dart';
import '../path_utils.dart';
import 'file_export.dart';

class FileExportIo implements FileExportService {
  static const String _appFolderName = 'file_structure_visualiser';
  static const String _createdFolderName = 'created';

  @override
  String get defaultLocationDisplay =>
      '$_appFolderName/$_createdFolderName';

  /// Absolute safe directory inside app documents area.
  Future<Directory> _getSafeOutputDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory(
      p.join(base.path, _appFolderName, _createdFolderName),
    );
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  @override
  Future<String> exportZip(List<Node> roots) async {
    final bytes = _buildZipBytes(roots);
    final outDir = await _getSafeOutputDir();
    final filename = PathUtils.defaultZipFileName();
    final outFile = File(p.join(outDir.path, filename));

    await outFile.writeAsBytes(bytes, flush: true);
    return outFile.path;
  }

  Uint8List _buildZipBytes(List<Node> roots) {
    final archive = Archive();

    void addNode(Node n, String parentPath) {
      final safeName = PathUtils.sanitizeComponent(n.name);
      final currentPath = PathUtils.joinZip(parentPath, safeName);

      final isDirectory = n.isFolder || n.children.isNotEmpty;

      if (isDirectory) {
        archive.addFile(ArchiveFile('$currentPath/', 0, const []));
        for (final c in n.children) {
          addNode(c, currentPath);
        }
      } else {
        archive.addFile(ArchiveFile(currentPath, 0, const []));
      }
    }

    for (final r in roots) {
      addNode(r, '');
    }

    final encoded = ZipEncoder().encode(archive);
    return Uint8List.fromList(encoded ?? const <int>[]);
  }
}

FileExportService createFileExportServiceImpl() => FileExportIo();
