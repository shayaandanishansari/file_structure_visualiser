import 'package:flutter/material.dart';
import 'src/ui/tree_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FileStructureVisualiserApp());
}

class FileStructureVisualiserApp extends StatelessWidget {
  const FileStructureVisualiserApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TreeApp(),
    );
  }
}
