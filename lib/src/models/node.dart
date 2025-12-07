class Node {
  Node({
    required this.name,
    required this.isFolder,
    this.parent,
  });

  String name;
  bool isFolder;
  Node? parent;
  final List<Node> children = [];

  bool get isRoot => parent == null;

  int get depth {
    int d = 0;
    for (Node? p = parent; p != null; p = p.parent) {
      d++;
    }
    return d;
  }

  /// Ancestors from root..parent
  List<Node> get lineage {
    final list = <Node>[];
    for (Node? p = parent; p != null; p = p.parent) {
      list.insert(0, p);
    }
    return list;
  }
}
