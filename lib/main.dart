import 'package:flutter/material.dart';

void main() {
  runApp(const ShelfshapApp());
}

class ShelfItem {
  String name;
  ShelfItem({required this.name});
}

class Shelf {
  String name;
  List<ShelfItem> items;
  Shelf({required this.name, required this.items});
}

class ShelfshapApp extends StatelessWidget {
  const ShelfshapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.brown[800],
          foregroundColor: Colors.white,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.brown[800],
          foregroundColor: Colors.white,
        ),
      ),
      home: const ShelfHome(),
    );
  }
}

class ShelfHome extends StatefulWidget {
  const ShelfHome({super.key});

  @override
  State<ShelfHome> createState() => _ShelfHomeState();
}

class _ShelfHomeState extends State<ShelfHome> {
  final List<Shelf> _shelves = [
    Shelf(name: "Shelf 1", items: [
      ShelfItem(name: "Hardcover Book"),
      ShelfItem(name: "Notebook"),
    ]),
    Shelf(name: "Shelf 2", items: [
      ShelfItem(name: "Digital Camera"),
    ]),
  ];

  // =========================
  // Variables & Data Types
  // =========================
  int totalShelves = 0;
  int totalItems = 0;// int
  double averageItems = 0.0; // double
  bool hasManyShelves = false; // bool
  String shelfStatus = "";   // String
  String itemSummary = "";

  // =========================
  // Calculate Stats
  // =========================
  void _calculateStats() {
    totalShelves = _shelves.length;

    totalItems = 0;
    itemSummary = "";

    for (int i = 0; i < _shelves.length; i++) {
      int itemCount = _shelves[i].items.length;
      totalItems += itemCount;

      itemSummary += "${_shelves[i].name}: $itemCount items\n";
    }

    // Arithmetic operations
    averageItems = totalShelves > 0 ? totalItems / totalShelves : 0;

    // FIXED LOGIC (only depends on shelf count now)
    hasManyShelves = totalShelves >= 5;

    // Collective status using shelves + items
    int collectiveTotal = totalShelves + totalItems;

    if (collectiveTotal == 0) {
      shelfStatus = "No shelves and no items available";
    } else if (collectiveTotal <= 5) {
      shelfStatus = "Small storage collection";
    } else if (collectiveTotal <= 15) {
      shelfStatus = "Growing storage collection";
    } else {
      shelfStatus = "Large storage collection";
    }

    // Debug
    print("Total Shelves: $totalShelves");
    print("Total Items: $totalItems");
    print("Average Items: $averageItems");
    print("Has Many Shelves: $hasManyShelves");
    print("Collective Total: $collectiveTotal");
  }

  @override
  void initState() {
    super.initState();
    _calculateStats();
  }

  // =========================
  // Add / Rename / Delete Shelf
  // =========================
  void _addNewShelf() {
    setState(() {
      _shelves.add(Shelf(name: "Shelf ${_shelves.length + 1}", items: []));
      _calculateStats();
    });
  }

  void _renameShelf(int index) {
    final controller = TextEditingController(text: _shelves[index].name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename Shelf"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => _shelves[index].name = controller.text);
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteShelf(int index) {
    setState(() {
      _shelves.removeAt(index);
      _calculateStats();
    });
  }

  // =========================
  // Add / Rename / Delete Item
  // =========================
  void _addItem(int shelfIndex) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Item"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _shelves[shelfIndex].items.add(ShelfItem(name: controller.text));
                  _calculateStats();
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _renameItem(int shelfIndex, int itemIndex) {
    final controller = TextEditingController(text: _shelves[shelfIndex].items[itemIndex].name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename Item"),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() {
                  _shelves[shelfIndex].items[itemIndex].name = controller.text;
                  _calculateStats();
                });
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  void _deleteItem(int shelfIndex, int itemIndex) {
    setState(() {
      _shelves[shelfIndex].items.removeAt(itemIndex);
      _calculateStats();
    });
  }

  // =========================
  // Confirm Delete
  // =========================
  void _confirmDelete({required String title, required VoidCallback onDelete}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: const Text("Are you sure you want to delete this?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(onPressed: () { onDelete(); Navigator.pop(context); }, child: const Text("Delete")),
        ],
      ),
    );
  }

  // =========================
  // Build Shelf Widget
  // =========================
  Widget _buildShelf(int sIndex) {
    final shelf = _shelves[sIndex];
    return DragTarget<Map<String, dynamic>>(
      onWillAccept: (_) => true,
      onAccept: (data) {
        if (data['type'] == 'item') {
          final fromShelf = data['shelfIndex'];
          final fromItem = data['itemIndex'];
          if (fromShelf != sIndex) {
            setState(() {
              final item = _shelves[fromShelf].items.removeAt(fromItem);
              _shelves[sIndex].items.add(item);
              _calculateStats();
            });
          }
        }
      },
      builder: (context, candidate, rejected) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Shelf title + rename + delete
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _renameShelf(sIndex),
                      child: Text(shelf.name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.brown),
                    onPressed: () => _confirmDelete(
                      title: "Delete Shelf",
                      onDelete: () => _deleteShelf(sIndex),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Items
              Wrap(
                spacing: 14,
                runSpacing: 8,
                children: shelf.items.asMap().entries.map((entry) {
                  final iIndex = entry.key;
                  final item = entry.value;
                  return Draggable<Map<String, dynamic>>(
                    data: {'type': 'item', 'shelfIndex': sIndex, 'itemIndex': iIndex},
                    feedback: Material(
                      color: Colors.transparent,
                      child: Opacity(
                        opacity: 0.7,
                        child: ActionChip(label: Text(item.name), backgroundColor: Colors.brown[50]),
                      ),
                    ),
                    childWhenDragging: Opacity(
                      opacity: 0.3,
                      child: ActionChip(label: Text(item.name), backgroundColor: Colors.brown[50]),
                    ),
                    child: ActionChip(
                      label: Text(item.name),
                      backgroundColor: Colors.brown[50],
                      onPressed: () => _renameItem(sIndex, iIndex),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),

              // Add item button
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: () => _addItem(sIndex),
                  icon: const Icon(Icons.add),
                  label: const Text("Add Item"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // =========================
  // Build Method
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Shelfshap", style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          DragTarget<Map<String, dynamic>>(
            onAccept: (data) {
              if (data['type'] == 'item') {
                _confirmDelete(title: "Delete Item", onDelete: () => _deleteItem(data['shelfIndex'], data['itemIndex']));
              } else if (data['type'] == 'shelf') {
                _confirmDelete(title: "Delete Shelf", onDelete: () => _deleteShelf(data['shelfIndex']));
              }
            },
            builder: (context, candidate, rejected) => Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Icon(Icons.delete, size: 28, color: candidate.isNotEmpty ? Colors.orange : Colors.white70),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          // Display variables for academic requirements
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.brown[50],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Total Shelves: $totalShelves"),
                Text("Total Items: $totalItems"),
                Text("Average Items per Shelf: ${averageItems.toStringAsFixed(2)}"),
                Text("Has Many Shelves (>=5): $hasManyShelves"),
                const SizedBox(height: 6),
                const Text("Items Per Shelf:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text(itemSummary),
                const SizedBox(height: 6),
                Text("Overall Status: $shelfStatus",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),

          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _shelves.length,
              itemBuilder: (context, index) => Draggable<Map<String, dynamic>>(
                data: {'type': 'shelf', 'shelfIndex': index},
                feedback: Material(
                  color: Colors.transparent,
                  child: Opacity(opacity: 0.7, child: _buildShelf(index)),
                ),
                childWhenDragging: Opacity(opacity: 0.3, child: _buildShelf(index)),
                child: _buildShelf(index),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewShelf,
        icon: const Icon(Icons.add),
        label: const Text("New Shelf"),
      ),
    );
  }
}
