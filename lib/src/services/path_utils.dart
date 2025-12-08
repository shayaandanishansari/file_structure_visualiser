import 'package:path/path.dart' as p;

/// Utilities focused on *safe naming* for ZIP entry paths.
///
/// We are intentionally NOT dealing with arbitrary user filesystem paths
/// in V1 to keep the app safe and predictable.
class PathUtils {
  static final RegExp _badChars = RegExp(r'[<>:"/\\|?*\x00-\x1F]');

  /// Sanitize a single file/folder name component.
  static String sanitizeComponent(String raw) {
    final t = raw.replaceAll(_badChars, '_').trim();
    return t.isEmpty ? 'untitled' : t;
  }

  /// Builds a safe ZIP path (always uses forward slashes internally).
  static String joinZip(String a, String b) {
    if (a.isEmpty) return b;
    return p.posix.join(a, b);
  }

  /// Simple timestamped filename.
  static String defaultZipFileName({String prefix = 'file_structure'}) {
    final now = DateTime.now();
    final stamp =
        '${now.year}${_two(now.month)}${_two(now.day)}_${_two(now.hour)}${_two(now.minute)}${_two(now.second)}';
    return '${prefix}_$stamp.zip';
  }

  static String _two(int v) => v.toString().padLeft(2, '0');
}
