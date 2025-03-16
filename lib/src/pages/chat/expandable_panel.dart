import 'dart:math';

import 'package:flutter/material.dart';

class ExpandablePanel extends StatefulWidget {
  bool expand;
  Widget? title;
  Widget? collapsedIcon;
  Widget? expandedIcon;
  final EdgeInsetsGeometry? padding;
  final Widget child;
  final Function(bool)? onExpandedChanged;
  ExpandablePanel({
    super.key,
    this.padding,
    this.title,
    required this.child,
    this.collapsedIcon,
    this.expandedIcon,
    this.expand = false,
    this.onExpandedChanged,
  });
  @override
  _ExpandablePanelState createState() => _ExpandablePanelState();
}

class _ExpandablePanelState extends State<ExpandablePanel> {
  late bool _expand;
  @override
  void initState() {
    super.initState();
    _expand = widget.expand;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (build, constraints) {
      return SizedBox(
        width: constraints.maxWidth,
        child: AnimatedSize(
          alignment: Alignment.topLeft,
          duration: Duration(milliseconds: 300),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: widget.title != null
                        ? widget.title!
                        : SizedBox.shrink(),
                  ),
                  MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        child: Padding(
                            padding: EdgeInsets.all(5),
                            child: AnimatedSwitcher(
                              duration: Duration(milliseconds: 300),
                              transitionBuilder: (child, animation) {
                                final flipAnimation = Tween(begin: pi, end: 0.0)
                                    .animate(animation);
                                return AnimatedBuilder(
                                  animation: flipAnimation,
                                  child: child,
                                  builder: (context, child) {
                                    final angle = flipAnimation.value;
                                    return Transform(
                                      alignment: Alignment.center,
                                      transform: Matrix4.rotationX(angle),
                                      child: child,
                                    );
                                  },
                                );
                              },
                              child: _expand
                                  ? widget.collapsedIcon ??
                                      Icon(
                                        Icons.keyboard_arrow_up,
                                        key: ValueKey(true),
                                      )
                                  : widget.expandedIcon ??
                                      Icon(
                                        Icons.keyboard_arrow_down,
                                        key: ValueKey(false),
                                      ),
                            )),
                        onTap: () {
                          setState(() {
                            _expand = !_expand;
                            if (widget.onExpandedChanged != null) {
                              widget.onExpandedChanged!(_expand);
                            }
                          });
                        },
                      ))
                ],
              ),
              if (_expand) Divider(),
              Visibility(
                visible: _expand,
                maintainAnimation: false,
                maintainState: false,
                maintainSize: false,
                child: widget.child,
              ),
            ],
          ),
        ),
      );
    });
  }
}
