import 'dart:math';

import 'package:chat/widgets/custom_tab/controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomTab extends StatefulWidget {
  final CustomTabController controller;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? backgroundColor;
  final Color? hoverColor;
  final Color? activeColor;
  const CustomTab({
    super.key,
    required this.controller,
    this.padding = const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
    this.radius = 8,
    this.backgroundColor,
    this.hoverColor,
    this.activeColor,
  });

  @override
  _CustomTabState createState() => _CustomTabState();
}

class _CustomTabState extends State<CustomTab> {
  CsTabController _controller = CsTabController();
  final ButtonStyle _buttonStyle = ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))));
  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateUi);
    widget.controller.addListener(_updateUi);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateUi);
    widget.controller.removeListener(_updateUi);
    super.dispose();
  }

  void _updateUi() {
    setState(() {});
  }

  Color getRandomColor() {
    // 创建一个Random实例
    final random = Random();

    // 使用Random实例生成颜色的RGB值
    return Color.fromARGB(
      255, // 不透明度（Alpha），设置为255表示完全不透明
      random.nextInt(256), // 红色值 (0-255)
      random.nextInt(256), // 绿色值 (0-255)
      random.nextInt(256), // 蓝色值 (0-255)
    );
  }

  List<Widget> getChildren() {
    List<Widget> children = [];
    for (int i = 0; i < widget.controller.items.length; i++) {
      CsShape shape = CsShape.none;
      if (_controller.currentIndex >= 0) {
        if (i == _controller.currentIndex) {
          shape = CsShape.mShape;
        } else if (i == _controller.currentIndex - 1) {
          shape = CsShape.lShape;
        } else if (i == _controller.currentIndex + 1) {
          shape = CsShape.rShape;
        }
      }

      if (_controller.hoverIndex >= 0 && !(i == _controller.currentIndex)) {
        if (i == _controller.hoverIndex) {
          shape = CsShape.mShape;
        } else if (i == _controller.hoverIndex) {
          shape = CsShape.mShape;
        } else if (i == _controller.hoverIndex - 1) {
          shape = CsShape.lShape;
        } else if (i == _controller.hoverIndex + 1) {
          shape = CsShape.rShape;
        }
        if (_controller.hoverIndex == _controller.currentIndex + 1) {
          shape = CsShape.rShape;
        } else if (_controller.hoverIndex == _controller.currentIndex - 1) {
          shape = CsShape.lShape;
        }
      }
      if (_controller.hoverIndex >= 0 &&
          i == _controller.hoverIndex &&
          _controller.currentIndex == -1) {
        shape = CsShape.mShape;
      }
      if (_controller.currentIndex >= 0 && _controller.hoverIndex >= 0) {
        if (i == _controller.currentIndex + 1 &&
            (i == _controller.hoverIndex - 1 ||
                i == _controller.hoverIndex + 2)) {
          shape = CsShape.rShape;
        }
      }

      children.add(ShapeButton(
        activeColor: widget.activeColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 59, 59, 59)
                : const Color.fromARGB(255, 247, 247, 247)),
        hoverColor: widget.hoverColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 42, 42, 42)
                : const Color.fromARGB(255, 218, 218, 218)),
        onHover: (value) {
          if (value) {
            _controller.setHoverIndex(i);
          } else {
            _controller.setHoverIndex(-1);
          }
        },
        onTap: () {
          _controller.setIndex(i);
        },
        active: _controller.currentIndex == i,
        shape: shape,
        color: widget.backgroundColor ??
            (Theme.of(context).brightness == Brightness.dark
                ? const Color.fromARGB(255, 32, 32, 32)
                : const Color.fromARGB(255, 205, 205, 205)),
        padding: widget.padding,
        radius: widget.radius,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              widget.controller.items[i].icon,
              size: 16,
            ),
            SizedBox(
              width: 5,
            ),
            Text(widget.controller.items[i].label),
            SizedBox(
              width: 5,
            ),
            TabIconButton(
              onPressed: () {
                widget.controller.removeTab(i);
              },
              icon: Icon(
                Icons.close,
                size: 16,
              ),
            )
          ],
        ),
      ));
    }
    return children;
  }

  @override
  Widget build(BuildContext context) {
    return DragTarget<TabItem>(builder: (context, accepted, rejected) {
      return Container(
          alignment: Alignment.topCenter,
          color: widget.activeColor ??
              (Theme.of(context).brightness == Brightness.dark
                  ? const Color.fromARGB(255, 59, 59, 59)
                  : const Color.fromARGB(255, 247, 247, 247)),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                    width: 0,
                    color: widget.activeColor ??
                        (Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 59, 59, 59)
                            : const Color.fromARGB(255, 247, 247, 247)),
                  ) // 边框宽度设为0
                      ),
                  color: widget.backgroundColor ??
                      (Theme.of(context).brightness == Brightness.dark
                          ? const Color.fromARGB(255, 32, 32, 32)
                          : const Color.fromARGB(255, 205, 205, 205)),
                ),
                padding: EdgeInsets.only(left: 5, right: 5, top: 5, bottom: 0),
                child: Row(children: [
                  _TabRenderWidget(
                    backgroundColor: Colors.transparent,
                    radius: widget.radius,
                    padding: widget.padding,
                    borderWidth: 1,
                    controller: _controller,
                    children: getChildren(),
                  ),
                  TabIconButton(
                    onPressed: () {
                      widget.controller.addTab(TabItem(icon: Icons.accessible,label: "New Tab"));
                    },
                    icon: Icon(
                      Icons.add,
                      size: 20,
                    ),
                  )
                ]),
              ),
              Expanded(child: Container())
            ],
          ));
    });
  }
}

class TabIconButton extends StatefulWidget {
  final VoidCallback onPressed;
  final Widget icon;
  const TabIconButton({super.key, required this.onPressed, required this.icon});

  @override
  State<StatefulWidget> createState() => _TabIconButtonState();
}

class _TabIconButtonState extends State<TabIconButton> {
  bool _hover = false;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      customBorder: CircleBorder(),
      onHover: (value) {
        setState(() {
          _hover = value;
        });
      },
      onTap: widget.onPressed,
      child: Container(
        decoration: BoxDecoration(
          color: _hover ? Theme.of(context).hoverColor : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: widget.icon,
      ),
    );
  }
}

class CsTabController extends ChangeNotifier {
  int _currentIndex = -1;
  int _hoverIndex = -1;
  int get currentIndex => _currentIndex;
  int get hoverIndex => _hoverIndex;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setHoverIndex(int index) {
    _hoverIndex = index;
    notifyListeners();
  }
}

class TabItem {
  final String label;
  final IconData icon;
  TabItem({required this.label, required this.icon});
}

class TabBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double radius = 8;
    const double width = 120;
    double start = 100;
    final Paint paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;
    Path path = Path();
    for (int i = 0; i < 4; i++) {
      path.moveTo(start, size.height);
      path.arcToPoint(Offset(start + radius, size.height - radius),
          radius: Radius.circular(radius), clockwise: false);
      path.lineTo(start + radius, radius);
      path.arcToPoint(Offset(start + 2 * radius, 0),
          radius: Radius.circular(radius), clockwise: true);
      path.lineTo(start + width - 4 * radius, 0);
      path.arcToPoint(Offset(start + width - 3 * radius, radius),
          radius: Radius.circular(radius), clockwise: true);
      path.lineTo(start + width - 3 * radius, size.height - radius);
      path.arcToPoint(Offset(start + width - 2 * radius, size.height),
          radius: Radius.circular(radius), clockwise: false);
      start += width * 2;
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    // TODO: implement shouldRepaint
    return true;
  }
}

class _TabRenderWidget extends MultiChildRenderObjectWidget {
  final double radius;
  final EdgeInsetsGeometry padding;

  final Color backgroundColor;
  final double borderWidth;
  final CsTabController controller;
  const _TabRenderWidget({
    required super.children,
    required this.radius,
    required this.padding,
    required this.controller,
    required this.borderWidth,
    required this.backgroundColor,
  });

  @override
  TabRenderBox createRenderObject(BuildContext context) {
    return TabRenderBox(
      radius: radius,
      padding: padding,
      borderWidth: borderWidth,
      controller: controller,
      backgroundColor: backgroundColor,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant TabRenderBox renderObject) {
    renderObject
      ..radius = radius
      ..padding = padding
      ..controller = controller
      ..backgroundColor = backgroundColor;
  }

  @override
  MultiChildRenderObjectElement createElement() {
    return _TabViewElement(this);
  }
}

class _TabViewElement extends MultiChildRenderObjectElement {
  _TabViewElement(MultiChildRenderObjectWidget widget) : super(widget);

  @override
  void insertRenderObjectChild(RenderObject child, dynamic slot) {
    final parentData =
        child.parentData as BoxParentData? ?? TabLayoutParentData();
    child.parentData = parentData;
    super.insertRenderObjectChild(child, slot);
  }
}

class TabLayoutParentData extends ContainerBoxParentData<RenderBox> {}

class TabRenderBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, TabLayoutParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, TabLayoutParentData> {
  double radius;
  EdgeInsetsGeometry padding;
  Color backgroundColor;
  final double borderWidth;
  CsTabController controller;

  TabRenderBox({
    required this.radius,
    required this.controller,
    required this.padding,
    required this.borderWidth,
    required this.backgroundColor,
  });

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    double offsetX = 0;
    double offsetY = 0;
    double h = 0;

    for (RenderBox child in getChildrenAsList()) {
      child.layout(BoxConstraints.loose(constraints.biggest),
          parentUsesSize: true);
      final TabLayoutParentData childParentData =
          child.parentData! as TabLayoutParentData;
      childParentData.offset = Offset(offsetX, offsetY);
      offsetX += child.size.width - 2 * radius;
      h = child.size.height;
    }
    size = Size(offsetX + 2 * radius, h);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var children = getChildrenAsList();
    if (children.isEmpty) return;
    bool drawSplit = true;
    double startX = offset.dx;
    double startY = offset.dy;
    final Paint bgPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;
    context.canvas.drawRect(offset & size, bgPaint);
    final Paint linePaint = Paint()
      ..color = const Color.fromARGB(255, 131, 131, 131)
      ..style = PaintingStyle.stroke;
    RenderBox child = children.first;
    if (controller.currentIndex != 0 && controller.hoverIndex != 0) {
      context.canvas.drawLine(
          Offset(startX + radius, startY + radius),
          Offset(startX + radius, startY + child.size.height - radius),
          linePaint);
    }

    for (int i = 0; i < children.length; i++) {
      final TabLayoutParentData childParentData =
          children[i].parentData! as TabLayoutParentData;
      context.paintChild(children[i], childParentData.offset + offset);
      if (controller.currentIndex >= 0 || controller.hoverIndex >= 0) {
        if (controller.currentIndex == i + 1 ||
            controller.currentIndex == i ||
            controller.hoverIndex == i + 1 ||
            controller.hoverIndex == i) {
          drawSplit = false;
        } else {
          drawSplit = true;
        }
      }

      if (drawSplit) {
        context.canvas.drawLine(
            Offset(startX - radius + children[i].size.width, startY + radius),
            Offset(startX - radius + children[i].size.width,
                startY + children[i].size.height - radius),
            linePaint);
      }
      startX += children[i].size.width - 2 * radius;
    }
  }
}

class ShapeButton extends StatefulWidget {
  final Widget child;
  final Color color;
  final Color activeColor;
  final Color hoverColor;
  final CsShape shape;
  final Function()? onTap;
  final Function(bool)? onHover;
  final bool active;
  final EdgeInsetsGeometry padding;
  final double radius;
  // 拖动开始事件
  final Function? onDragStarted;
  // 拖动完成事件
  final Function? onDragCompleted;
  // 拖动取消事件
  final Function? onDraggableCanceled;

  const ShapeButton({
    super.key,
    required this.shape,
    required this.child,
    required this.active,
    required this.padding,
    required this.radius,
    required this.activeColor,
    required this.hoverColor,
    this.onTap,
    this.onHover,
    this.color = Colors.transparent,
    this.onDragStarted,
    this.onDragCompleted,
    this.onDraggableCanceled,
  });

  @override
  State<ShapeButton> createState() => _ShapeButtonState();
}

class _ShapeButtonState extends State<ShapeButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    Color _color = widget.active ? widget.activeColor : widget.color;
    if (_hovered && !widget.active) {
      _color = widget.hoverColor;
    }
    EdgeInsets actualPadding = widget.padding.resolve(TextDirection.ltr);

    return Draggable(
        onDragCompleted: () {
          if (widget.onDragCompleted != null) {
            widget.onDragCompleted!();
          }
        },
        onDragStarted: () {
          if (widget.onDragStarted != null) {
            widget.onDragStarted!();
          }
        },
        onDraggableCanceled: (velocity, offset) {
          if (widget.onDraggableCanceled != null) {
            widget.onDraggableCanceled!();
          }
        },
        feedback: Material(
          child: Container(
            child: Text("test"),
          ),
        ),
        child: ClipPath(
          clipper: ShapClipper(
            shape: widget.shape,
            radius: widget.radius,
            padding: widget.padding,
          ),
          child: InkWell(
            onTap: () {
              if (widget.onTap != null) {
                widget.onTap!();
              }
            },
            onHover: (value) {
              if (widget.onHover != null) {
                widget.onHover!(value);
              }
              setState(() {
                _hovered = value;
              });
            },
            child: Container(
              padding: EdgeInsets.only(
                left: actualPadding.left + widget.radius,
                right: actualPadding.right + widget.radius,
                top: actualPadding.top,
                bottom: actualPadding.bottom,
              ),
              color: _color,
              child: widget.child,
            ),
          ),
        ));
  }
}

enum CsShape { lShape, mShape, rShape, none }

class ShapClipper extends CustomClipper<Path> {
  final CsShape shape;
  final double radius;
  final EdgeInsetsGeometry padding;
  const ShapClipper(
      {required this.shape, required this.radius, required this.padding});

  @override
  Path getClip(Size size) {
    double startX = 0;
    double startY = 0;
    double width = size.width;
    double height = size.height;
    Path path = Path();
    bool isRSide = shape == CsShape.rShape;
    bool isLSide = shape == CsShape.lShape;
    bool isNone = shape == CsShape.none;
    if (isNone || radius == 0) {
      path.addRect(
          Rect.fromLTWH(startX + radius, startY, width - 2 * radius, height));
      return path;
    }
    path.moveTo(startX + (isRSide ? 2 : 0) * radius, startY + height);
    path.arcToPoint(Offset(startX + radius, startY + height - radius),
        radius: Radius.circular(radius), clockwise: isRSide);
    path.lineTo(startX + radius, startY + radius);
    path.arcToPoint(Offset(startX + (isRSide ? 0 : 2) * radius, startY),
        radius: Radius.circular(radius), clockwise: !isRSide);
    path.lineTo(startX + width - (isLSide ? 0 : 2) * radius, startY);
    path.arcToPoint(Offset(startX + width - radius, startY + radius),
        radius: Radius.circular(radius), clockwise: !isLSide);
    path.lineTo(startX + width - radius, startY + height - radius);
    path.arcToPoint(
        Offset(startX + width - (isLSide ? 2 : 0) * radius, startY + height),
        radius: Radius.circular(radius),
        clockwise: isLSide);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant ShapClipper oldClipper) {
    return true; // 如果 shape 发生变化，则返回 true 以重新绘制
  }
}
