import 'package:flutter/material.dart';

class CusIconButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final Color? backgroundColor;
  final Color? color;
  final bool? shadow;
  const CusIconButton(
      {super.key,
      this.onPressed,
      required this.icon,
      this.backgroundColor,
      this.color,
      this.shadow = true,});

  @override
  State<StatefulWidget> createState() => _CusIconButtonState();
}

class _CusIconButtonState extends State<CusIconButton> {
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
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: _hover && widget.onPressed != null
                ? Theme.of(context).hoverColor
                : widget.backgroundColor ??
                    Theme.of(context).buttonTheme.colorScheme!.onPrimary,
            shape: BoxShape.circle,
            boxShadow: [
              if (!_hover && widget.shadow!)
                BoxShadow(
                  color: Colors.black.withAlpha(50), // 阴影的颜色
                  offset: Offset(0.8, 0.8), // 阴影与容器的距离
                  blurRadius: 0.5, // 高斯的标准偏差与盒子的形状卷积。
                  spreadRadius: 0.0, // 在应用模糊之前，框应该膨胀的量。
                ),
            ]),
        child: widget.icon,
      ),
    );
  }
}
