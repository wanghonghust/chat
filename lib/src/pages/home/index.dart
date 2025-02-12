import 'dart:io';
import 'dart:math';
import 'dart:ui';

import 'package:animated_size_and_fade/animated_size_and_fade.dart';
import 'package:chat/src/pages/chat/toggle_button.dart';
import 'package:envied/envied.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int count = 0;
  final MaterialTextSelectionControls materialTextControls =
      MaterialTextSelectionControls();
  bool isDesktop = Platform.isWindows || Platform.isMacOS || Platform.isLinux;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ExpandableContainer(
          children: [
            ToggleButton(
              onSelected: (v) {},
              icon: Icon(Icons.menu),
              label: Text("搜索"),
            ),
            IconButton.filled(onPressed: () {}, icon: Icon(Icons.home)),
            IconButton.filled(onPressed: () {}, icon: Icon(Icons.add)),
            IconButton.filled(onPressed: () {}, icon: Icon(Icons.menu)),
            IconButton.filled(onPressed: () {}, icon: Icon(Icons.menu))
          ],
        ),
      ),
    );
  }
}

class ExpandableContainer extends StatefulWidget {
  bool expand;
  Widget? collapsedIcon;
  Widget? expandedIcon;
  final EdgeInsetsGeometry? padding;
  final List<Widget> children;
  ExpandableContainer({
    super.key,
    this.padding,
    required this.children,
    this.collapsedIcon,
    this.expandedIcon,
    this.expand = false,
  });
  @override
  _ExpandContainerState createState() => _ExpandContainerState();
}

class _ExpandContainerState extends State<ExpandableContainer> {
  late bool _expand;
  @override
  void initState() {
    super.initState();
    _expand = widget.expand;
  }

  @override
  Widget build(BuildContext context) {
    return UnconstrainedBox(
        alignment: Alignment.centerLeft,
        child: Container(
            padding: widget.padding,
            decoration: ShapeDecoration(
              shape: StadiumBorder(),
              color: Theme.of(context).hoverColor,
            ),
            child: AnimatedSize(
              duration: Duration(milliseconds: 200),
              child: Row(
                // mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    child: Padding(
                      padding: EdgeInsets.all(5),
                      child: _expand
                          ? widget.collapsedIcon ?? Icon(Icons.remove)
                          : widget.expandedIcon ?? Icon(Icons.drag_handle),
                    ),
                    onTap: () {
                      setState(() {
                        _expand = !_expand;
                      });
                    },
                  ),
                  if (_expand)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      mainAxisSize: MainAxisSize.min,
                      children: widget.children,
                    ),
                ],
              ),
            )));
  }
}
