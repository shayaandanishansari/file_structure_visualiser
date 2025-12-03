import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: TreeApp()));
}

/// ---------- DATA MODEL ----------
class Node {
  Node({required this.name, required this.isFolder, this.parent});

  String name;
  bool isFolder;
  Node? parent;
  final List<Node> children = [];

  bool get isRoot => parent == null;

  int get depth {
    int d = 0;
    for (Node? p = parent; p != null; p = p.parent) d++;
    return d;
  }

  /// ancestors from root..parent
  List<Node> get lineage {
    final list = <Node>[];
    for (Node? p = parent; p != null; p = p.parent) {
      list.insert(0, p);
    }
    return list;
  }
}

/// ---------- APP ----------
class TreeApp extends StatefulWidget {
  const TreeApp({super.key});
  @override
  State<TreeApp> createState() => _TreeAppState();
}

class _TreeAppState extends State<TreeApp> {
  final List<Node> roots = [];
  Node? selected;

  // inline rename
  Node? editingNode;
  final TextEditingController _editCtrl = TextEditingController();
  final FocusNode _editFocus = FocusNode();

  final TextEditingController pathCtrl =
      TextEditingController(text: r'C:\Users\Public\LPT_Scaffold');

  @override
  void initState() {
    super.initState();
    final project = Node(name: 'Project', isFolder: true);
    roots.add(project);
    selected = project;
  }

  @override
  void dispose() {
    _editCtrl.dispose();
    _editFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D1C),
      body: SafeArea(
        child: Stack(
          children: [
            // Top bar
            Positioned(
              left: 20,
              right: 20,
              top: 12,
              child: Row(
                children: [
                  Expanded(child: _pathBox()),
                  const SizedBox(width: 10),
                  _iconBtn(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete selected (and children)',
                    onTap: _deleteSelectedImmediate,
                  ),
                  const SizedBox(width: 10),
                  _iconBtn(
                    icon: Icons.download_rounded,
                    tooltip: 'Export batch script',
                    onTap: _exportBatch,
                  ),
                ],
              ),
            ),

            // Canvas
            Positioned.fill(
              top: 64,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF0A0B18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: InteractiveViewer(
                    constrained: false,
                    boundaryMargin: const EdgeInsets.all(1000),
                    minScale: 0.5,
                    maxScale: 2.25,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: _buildForest(),
                    ),
                  ),
                ),
              ),
            ),

            // Controls
            Positioned(
              right: 26,
              bottom: 26,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _controlPanel(
                    title: 'Folder',
                    color: const Color(0xFF30B05F),
                    onAddSibling: () => _addSibling(isFolder: true),
                    onAddChild: () => _addChild(isFolder: true),
                  ),
                  const SizedBox(height: 16),
                  _controlPanel(
                    title: 'File',
                    color: const Color(0xFFFA7A28),
                    onAddSibling: () => _addSibling(isFolder: false),
                    onAddChild: () => _addChild(isFolder: false),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------- TREE RENDER ----------
  Widget _buildForest() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [for (final r in roots) _buildSubtree(r)],
    );
  }

  Widget _buildSubtree(Node node) {
    final siblings = node.isRoot ? roots : node.parent!.children;
    final idx = siblings.indexOf(node);
    final isLast = idx == siblings.length - 1;

    final lineage = node.lineage;
    final ancestorHasMore = <bool>[];
    for (final anc in lineage) {
      final list = anc.isRoot ? roots : anc.parent!.children;
      ancestorHasMore.add(list.indexOf(anc) != list.length - 1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (int i = 0; i < ancestorHasMore.length; i++)
              CustomPaint(
                painter: _VerticalPainter(show: ancestorHasMore[i]),
                size: const Size(_Sizes.indent, _Sizes.nodeH),
              ),
            if (node.depth > 0)
              CustomPaint(
                painter: _ElbowPainter(continuesDown: !isLast),
                size: const Size(_Sizes.indent, _Sizes.nodeH),
              ),
            _nodeChip(node),
          ],
        ),
        if (node.children.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [for (final c in node.children) _buildSubtree(c)],
          ),
      ],
    );
  }

  Widget _nodeChip(Node n) {
    final isSel = identical(n, selected);
    final isEditing = identical(n, editingNode);
    final bg = n.isFolder ? const Color(0xFF2C2F41) : const Color(0xFF2A2330);
    final border = isSel ? Colors.white.withOpacity(.85) : Colors.white24;
    final icon = n.isFolder ? Icons.folder_rounded : Icons.insert_drive_file;

    final chip = Container(
      height: _Sizes.nodeH,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: isSel ? 2 : 1),
        boxShadow: [
          if (isSel)
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white.withOpacity(.9)),
          const SizedBox(width: 8),
          if (!isEditing)
            Text(
              n.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                letterSpacing: .2,
              ),
            )
          else
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 110, maxWidth: 260),
              child: IntrinsicWidth(
                child: TextField(
                  controller: _editCtrl,
                  focusNode: _editFocus,
                  autofocus: true,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: .2,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'name',
                    hintStyle: TextStyle(color: Colors.white54),
                  ),
                  onSubmitted: (val) => _commitRename(n, val),
                ),
              ),
            ),
        ],
      ),
    );

    return GestureDetector(
      onTap: () => setState(() => selected = n),
      onDoubleTap: () => _beginRename(n),
      child: chip,
    );
  }

  /// ---------- CONTROLS ----------
  Widget _pathBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF15172A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          const Icon(Icons.folder_open, color: Colors.white70, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: pathCtrl,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: r'Output path (e.g., C:\Projects\MyApp)',
                hintStyle: TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Tooltip(
      message: tooltip ?? '',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF24263A),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white24),
          ),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }

  Widget _controlPanel({
    required String title,
    required Color color,
    required VoidCallback onAddSibling,
    required VoidCallback onAddChild,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [BoxShadow(color: color.withOpacity(.3), blurRadius: 20, offset: const Offset(0, 8))],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _pillText(title),
          const SizedBox(height: 8),
          _panelBtn('Add Sibling', onAddSibling),
          const SizedBox(height: 8),
          _panelBtn('Add Child', onAddChild),
        ],
      ),
    );
  }

  Widget _panelBtn(String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 160,
        height: 42,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF2C2F41),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white70),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            letterSpacing: .2,
          ),
        ),
      ),
    );
  }

  Widget _pillText(String t) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2133),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        t,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, letterSpacing: .4),
      ),
    );
  }

  /// ---------- ACTIONS ----------
  void _addSibling({required bool isFolder}) {
    if (selected == null) {
      _toast('Select a node first.');
      return;
    }
    setState(() {
      final cur = selected!;
      final base = isFolder ? 'New Folder' : 'New File';
      if (cur.isRoot) {
        final n = Node(name: _uniqueName(roots, base), isFolder: isFolder);
        final i = roots.indexOf(cur);
        roots.insert(i + 1, n);
        // keep parent (current) selected
      } else {
        final list = cur.parent!.children;
        final n = Node(name: _uniqueName(list, base), isFolder: isFolder)..parent = cur.parent;
        final i = list.indexOf(cur);
        list.insert(i + 1, n);
        // keep parent (current) selected
      }
    });
  }

  void _addChild({required bool isFolder}) {
    if (selected == null) {
      _toast('Select a node first.');
      return;
    }
    setState(() {
      final cur = selected!;
      final base = isFolder ? 'New Folder' : 'New File';
      final n = Node(name: _uniqueName(cur.children, base), isFolder: isFolder)..parent = cur;
      cur.children.add(n);
      // keep parent selected (do not move selection to new child)
    });
  }

  void _deleteSelectedImmediate() {
    if (selected == null) {
      _toast('Nothing selected.');
      return;
    }
    setState(() {
      final target = selected!;
      if (target.isRoot) {
        final idx = roots.indexOf(target);
        roots.removeAt(idx);
        if (roots.isEmpty) {
          final fresh = Node(name: 'Project', isFolder: true);
          roots.add(fresh);
          selected = fresh;
        } else {
          selected = roots[(idx - 1).clamp(0, roots.length - 1)];
        }
      } else {
        final parent = target.parent!;
        final list = parent.children;
        final idx = list.indexOf(target);
        list.removeAt(idx);
        selected = parent; // move selection to parent
      }
      if (identical(editingNode, target)) {
        editingNode = null;
      }
    });
  }

  void _beginRename(Node n) {
    setState(() {
      editingNode = n;
      _editCtrl.text = n.name;
    });
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _editFocus.requestFocus();
        _editCtrl.selection =
            TextSelection(baseOffset: 0, extentOffset: _editCtrl.text.length);
      }
    });
  }

  void _commitRename(Node node, String raw) {
    final newName = _sanitizeName(raw);
    setState(() {
      node.name = newName;
      editingNode = null;
    });
  }

  String _uniqueName(List<Node> siblings, String base) {
    final existing = siblings.map((e) => e.name).toSet();
    if (!existing.contains(base)) return base;
    int i = 2;
    while (existing.contains('$base $i')) i++;
    return '$base $i';
  }

  String _sanitizeName(String s) {
    final t = s.trim();
    return t.isEmpty ? 'untitled' : t;
    }

  Future<void> _exportBatch() async {
    final base = pathCtrl.text.trim();
    if (base.isEmpty) {
      _toast('Please enter an output path.');
      return;
    }
    try {
      final script = _buildBatchScript(base);
      final dir = Directory(base);
      if (!dir.existsSync()) dir.createSync(recursive: true);

      final file =
          File('${dir.path}${Platform.pathSeparator}create_project.bat');
      file.writeAsStringSync(script);

      _toast('Saved: ${file.path}');
      if (Platform.isWindows) {
        try {
          await Process.run('explorer.exe', [dir.path]);
        } catch (_) {}
      }
    } catch (e) {
      _toast('Failed: $e');
    }
  }

  String _buildBatchScript(String basePath) {
    final b = StringBuffer();
    b.writeln('@echo off');
    b.writeln('setlocal enabledelayedexpansion');
    b.writeln('mkdir "${basePath}"');

    void walk(Node n, String cur) {
      final safe = _sanitizeFileComponent(n.name);
      final here = '$cur${Platform.pathSeparator}$safe';

      if (n.children.isNotEmpty || n.isFolder) {
        b.writeln('mkdir "$here"');
        for (final c in n.children) {
          walk(c, here);
        }
      } else {
        if (Platform.isWindows) {
          b.writeln('type NUL > "$here"');
        } else {
          b.writeln('touch "$here"');
        }
      }
    }

    for (final r in roots) {
      walk(r, basePath);
    }
    b.writeln('echo Done.');
    return b.toString();
  }

  String _sanitizeFileComponent(String s) {
    final bad = RegExp(r'[<>:"/\\|?*]');
    final t = s.replaceAll(bad, '_').trim();
    return t.isEmpty ? 'untitled' : t;
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

/// ---------- DRAWING HELPERS ----------
class _Sizes {
  static const double indent = 32;
  static const double nodeH = 40;
}

class _VerticalPainter extends CustomPainter {
  _VerticalPainter({required this.show});
  final bool show;

  @override
  void paint(Canvas canvas, Size size) {
    if (!show) return;
    final p = Paint()
      ..color = const Color(0xFF4B4E66)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final x = size.width / 2;
    canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
  }

  @override
  bool shouldRepaint(covariant _VerticalPainter old) => old.show != show;
}

class _ElbowPainter extends CustomPainter {
  _ElbowPainter({required this.continuesDown});
  final bool continuesDown;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = const Color(0xFF4B4E66)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;

    final cx = size.width / 2;
    final cy = size.height / 2;

    canvas.drawLine(Offset(cx, 0), Offset(cx, cy), p);           // vertical up
    canvas.drawLine(Offset(cx, cy), Offset(size.width, cy), p);  // elbow right
    if (continuesDown) {
      canvas.drawLine(Offset(cx, cy), Offset(cx, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant _ElbowPainter old) =>
      old.continuesDown != continuesDown;
}
