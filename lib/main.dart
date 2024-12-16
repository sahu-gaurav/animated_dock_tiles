import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Draggable Dock')),
        body: const Center(
          child: Dock(
            items: [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
          ),
        ),
      ),
    );
  }
}

/// Dock of the reorderable [items].
class Dock extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
  });

  final List<IconData> items;

  @override
  State<Dock> createState() => _DockState();
}

class _DockState extends State<Dock> {
  late List<IconData> _items;
  int? _hoveredIndex;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.items);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(_items.length, (index) {
          return _buildDraggableItem(_items[index], index);
        }),
      ),
    );
  }

  Widget _buildDraggableItem(IconData item, int index) {
    bool isHovered = _hoveredIndex == index;

    return MouseRegion(
      onEnter: (_) {
        setState(() {
          _hoveredIndex = index; // Track which item is being hovered
        });
      },
      onExit: (_) {
        setState(() {
          _hoveredIndex = null; // Reset when hover exits
        });
      },
      child: LongPressDraggable<IconData>(
        data: item,
        feedback: Material(
          color: Colors.transparent,
          child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              color: Colors.primaries[index % Colors.primaries.length],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Icon(item, color: Colors.white, size: 40),
            ),
          ),
        ),
        childWhenDragging: Container(),
        onDragCompleted: () {},
        child: DragTarget<IconData>(
          onWillAccept: (data) => data != item,
          onAccept: (data) {
            setState(() {
              int oldIndex = _items.indexOf(data);
              if (oldIndex != index) {
                _items.removeAt(oldIndex);
                _items.insert(index, data);
              }
            });
          },
          builder: (context, candidateData, rejectedData) {
            // Animate the scaling and shifting of the icons
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200), // Smooth animation
              height: 70,
              width: isHovered ? 80 : 70,  // Enlarge when hovered
              margin: EdgeInsets.symmetric(horizontal: isHovered ? 20 : 12),
              decoration: BoxDecoration(
                color: Colors.primaries[index % Colors.primaries.length],
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: isHovered
                        ? Colors.black.withOpacity(0.6)
                        : Colors.black.withOpacity(0.3),
                    spreadRadius: 1,
                    blurRadius: isHovered ? 12 : 6,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  item,
                  color: Colors.white,
                  size: isHovered ? 50 : 40, // Icon enlarges on hover
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
