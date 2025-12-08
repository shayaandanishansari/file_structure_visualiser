import '../../models/node.dart';

import 'file_export_unsupported.dart'
    if (dart.library.io) 'file_export_io.dart'
    if (dart.library.html) 'file_export_web.dart';

/// Platform-facing service API.
///
/// V1 safety design:
/// - Always export to ZIP.
/// - No arbitrary path input.
/// - Desktop/mobile: saves inside app documents area.
/// - Web: triggers browser download.
abstract class FileExportService {
  /// Human-readable location hint for UI.
  String get defaultLocationDisplay;

  /// Exports roots as a ZIP.
  ///
  /// Returns a user-meaningful message:
  /// - On IO platforms: absolute zip path.
  /// - On Web: "Download started".
  Future<String> exportZip(List<Node> roots);
}

/// Factory resolved by conditional import.
FileExportService createFileExportService() => createFileExportServiceImpl();
