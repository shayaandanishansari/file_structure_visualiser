import 'dart:io';

import 'package:archive/archive.dart';

import '../../models/node.dart';
import '../path_utils.dart';
import 'file_export.dart';

class IoFileExporter implements FileExporter {
  static const String _appFolder = 'file_structure_visualiser';
  static const String _createdFolder = 'created';

  @override
  String get defaultDisplayPath {
    final home = _homeDirPath();
    if (home == null) return 'file_structure_visualiser/created';
    return '${PathUtils.join(PathUtils.join(home, _appFolder, separator: Platform.pathSeparator), _createdFolder, separator: Platform.pathSeparator)}';
  }

  @override
  Future<ExportResult> exportZip(List<Node> roots) async {
    try {
      final bytes = _buildZipBytes(roots);

      final outDir = await _ensureDefaultOutputDir();
      final filename = _zipName();
      final outPath =
          PathUtils.join(outDir.path, filename, separator: Platform.pathSeparator);

      final file = File(outPath);
      await file.writeAsBytes(bytes, flush: true);

      return ExportResult(
        success: true,
        message: 'ZIP saved successfully.',
        savedPath: outPath,
      );
    } catch (e) {
      return ExportResult(
        success: false,
        message: 'ZIP export failed: $e',
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
      final path = prefix.isEmpty
          ? safe
          : PathUtils.join(prefix, safe, separator: '/');

      if (n.isFolder || n.children.isNotEmpty) {
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

  Future<Directory> _ensureDefaultOutputDir() async {
    final home = _homeDirPath();
    final base = home != null ? Directory(home) : Directory.current;

    final appPath = PathUtils.join(
      base.path,
      _appFolder,
      separator: Platform.pathSeparator,
    );
    final createdPath = PathUtils.join(
      appPath,
      _createdFolder,
      separator: Platform.pathSeparator,
    );

    final dir = Directory(createdPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  String? _homeDirPath() {
    return Platform.environment['USERPROFILE'] ??
        Platform.environment['HOME'];
  }
}

FileExporter createFileExporter() => IoFileExporter();
