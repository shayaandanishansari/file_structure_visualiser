/// Human-facing node name (used in the UI).
String sanitizeNodeName(String s) {
  final t = s.trim();
  return t.isEmpty ? 'untitled' : t;
}

/// File-system safe component (used when writing to disk / ZIP).
String sanitizeFileComponent(String s) {
  final bad = RegExp(r'[<>:"/\\|?*]');
  final t = s.replaceAll(bad, '_').trim();
  return t.isEmpty ? 'untitled' : t;
}
