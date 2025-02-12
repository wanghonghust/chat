import 'package:flutter/material.dart';

class ExpandableMenu extends StatefulWidget {
  bool? expand;
  ExpandableMenu({
    super.key,
    this.expand = false,
  });

  @override
  State<ExpandableMenu> createState() => _ExpandableMenuState();
}

class _ExpandableMenuState extends State<ExpandableMenu> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.menu),
        Icon(Icons.home),
        Icon(Icons.add),
        Icon(Icons.menu),
        Icon(Icons.menu),
      ],
    );
  }
}
