import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class CustomTab extends StatefulWidget {
  CustomTab({super.key});

  @override
  _CustomTabState createState() => _CustomTabState();
}

class _CustomTabState extends State<CustomTab> {
  final ButtonStyle _buttonStyle = ButtonStyle(
      shape: WidgetStateProperty.all<RoundedRectangleBorder>(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(5))));
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CustomPaint(
        //   painter: TabBarPainter(),
        //   size: Size(1200, 25),
        // ),
        _TabRenderWidget(
          height: 50,
          maxWidth: 200,
          borderColor: Colors.white,
          borderWidth: 1,
          children: [
            FilledButton.tonalIcon(
              style: _buttonStyle,
              onPressed: () {},
              icon: Icon(Icons.home),
              label: Text('Home'),
            ),
            FilledButton.tonalIcon(
              style: _buttonStyle,
              onPressed: () {},
              icon: Icon(Icons.menu),
              label: Text('Menu'),
            ),
            FilledButton.tonalIcon(
              style: _buttonStyle,
              onPressed: () {},
              icon: Icon(Icons.menu),
              label: Text('Menu'),
            ),
            FilledButton.tonalIcon(
              style: _buttonStyle,
              onPressed: () {},
              icon: Icon(Icons.menu),
              label: Text('Menu'),
            )
          ],
        )
      ],
    );
  }
}

class TabBarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const double radius = 8;
    const double width = 120;
    double start = 100;
    final Paint paint = Paint()
      ..color = Colors.white
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
  final BorderRadius? borderRadius;
  final double height;
  final double maxWidth;
  final Color borderColor;
  final double borderWidth;
  const _TabRenderWidget({
    required super.children,
    this.borderRadius,
    required this.height,
    required this.maxWidth,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  TabRenderBox createRenderObject(BuildContext context) {
    return TabRenderBox(
      borderRadius: borderRadius,
      height: height,
      maxWidth: maxWidth,
      borderColor: borderColor,
      borderWidth: borderWidth,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant TabRenderBox renderObject) {
    renderObject
      ..borderRadius = borderRadius
      ..height = height
      ..maxWidth = maxWidth;
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
  BorderRadius? borderRadius;
  double height;
  double maxWidth;
  Color borderColor;
  double borderWidth;

  TabRenderBox({
    this.borderRadius,
    required this.height,
    required this.maxWidth,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void performLayout() {
    double offsetX = 10;
    double offsetY = 5;
    for (RenderBox child in getChildrenAsList()) {
      child.layout(BoxConstraints(maxWidth: constraints.maxWidth),
          parentUsesSize: true);
      final TabLayoutParentData childParentData =
          child.parentData! as TabLayoutParentData;
      childParentData.offset = Offset(offsetX, offsetY);
      offsetX += child.size.width + 10;
    }

    size = Size(offsetX, height - 5);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    var children = getChildrenAsList();
    if (children.isEmpty) return;
    int currentIndex = 0;
    int index = 0;
    double startX = offset.dx;
    double startY = offset.dy;
    for (RenderBox child in children) {
      const double radius = 5;
      double width = child.size.width + 30;
      double height = child.size.height + 10;
      final Paint paint = Paint()
        ..color =
            index == currentIndex ? Colors.white : Colors.grey
        ..style = PaintingStyle.fill;
      Path path = Path();
      bool isRSide = index == currentIndex + 1;
      bool isLSide = index == currentIndex - 1;
      path.moveTo(startX + (isRSide ? 2 * radius : 0), startY + height);
      path.arcToPoint(Offset(startX + radius, startY + height - radius),
          radius: Radius.circular(radius), clockwise: isRSide);
      path.lineTo(startX + radius, startY + radius);
      path.arcToPoint(Offset(startX + (isRSide ? 0 : 2 * radius), startY),
          radius: Radius.circular(radius), clockwise: !isRSide);
      path.lineTo(startX + width - (isLSide ? 2 * radius : 4 * radius), startY);
      path.arcToPoint(Offset(startX + width - 3 * radius, startY + radius),
          radius: Radius.circular(radius), clockwise: !isLSide);
      path.lineTo(startX + width - 3 * radius, startY + height - radius);
      path.arcToPoint(Offset(startX + width - 2 * radius, startY + height),
          radius: Radius.circular(radius), clockwise: false);
      path.close();
      context.canvas.drawPath(path, paint);
      startX += width - 20;
      index++;
      final TabLayoutParentData childParentData =
          child.parentData! as TabLayoutParentData;
      context.paintChild(child, childParentData.offset + offset);
    }
  }
}
