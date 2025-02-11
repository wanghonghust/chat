import 'package:flutter/material.dart';

class MyIconButton extends StatefulWidget {
  Widget icon;
  Widget label;
  final Function()? onTap;

  MyIconButton({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  _MyIconButtonState createState() => _MyIconButtonState();
}

class _MyIconButtonState extends State<MyIconButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    if (_isHovered || widget.onTap == null) {
      color = Theme.of(context).hoverColor;
    }
    return Container(
      decoration:
          ShapeDecoration(shape: StadiumBorder(), color: color, shadows: [
        BoxShadow(
          color: Colors.black.withAlpha(50), // 阴影的颜色
          offset: Offset(0.8, 0.8), // 阴影与容器的距离
          blurRadius: 0.5, // 高斯的标准偏差与盒子的形状卷积。
          spreadRadius: 0.0, // 在应用模糊之前，框应该膨胀的量。
        ),
      ]),
      child: InkWell(
        customBorder: StadiumBorder(),
        onHover: (value) {
          setState(() {
            _isHovered = value;
          });
        },
        onTap: widget.onTap != null
            ? () {
                if (widget.onTap != null) {
                  widget.onTap!();
                }
              }
            : null,
        child: Padding(
            padding: EdgeInsets.only(top: 2, bottom: 2),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null)
                  Padding(
                    padding: EdgeInsets.only(left: 2, right: 2),
                    child: SizedBox(
                      width: 20,
                      height: 21,
                      child: widget.icon!,
                    ),
                  ),
                if (widget.label != null)
                  Padding(
                    padding: EdgeInsets.only(right: 15),
                    child: widget.label!,
                  )
              ],
            )),
      ),
    );
  }
}
