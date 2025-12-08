/// Utilities that are safe to use on all platforms (no dart:io here).

class PathUtils {
  /// Replace characters that are illegal or problematic across OSes.
  static String sanitizeComponent(String s) {
    final trimmed = s.trim();
    if (trimmed.isEmpty) return 'untitled';

    // Windows illegal: <>:"/\|?*
    // Also keep this conservative for cross-platform safety.
    final bad = RegExp(r'[<>:"/\\|?*\u0000-\u001F]');
    final cleaned = trimmed.replaceAll(bad, '_').trim();

    return cleaned.isEmpty ? 'untitled' : cleaned;
  }

  /// Creates a unique name within a sibling list.
  static String uniqueName(Iterable<String> existingNames, String base) {
    final existing = existingNames.toSet();
    if (!existing.contains(base)) return base;

    int i = 2;
    while (existing.contains('$base $i')) {
      i++;
    }
    return '$base $i';
  }

  /// Simple cross-platform join without depending on package:path.
  static String join(String a, String b, {String separator = '/'}) {
    if (a.isEmpty) return b;
    if (b.isEmpty) return a;
    final left = a.endsWith(separator) ? a.substring(0, a.length - 1) : a;
    final right = b.startsWith(separator) ? b.substring(1) : b;
    return '$left$separator$right';
  }
}
