import 'package:flutter/material.dart';

class ExpandablePanel extends StatefulWidget {
  final Widget child;
  bool expand;
  ExpandablePanel({super.key, required this.child, this.expand = false});

  @override
  _ExpandablePanelState createState() => _ExpandablePanelState();
}

class _ExpandablePanelState extends State<ExpandablePanel> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.transparent, borderRadius: BorderRadius.circular(2)),
      width: double.infinity,
      child: AnimatedSize(
        duration: Duration(milliseconds: 200),
        child: widget.expand
            ? Padding(
                padding: EdgeInsets.all(10),
                child: widget.child,
              )
            : SizedBox.shrink(),
      ),
    );
  }
}
