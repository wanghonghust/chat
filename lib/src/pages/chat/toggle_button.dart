import 'dart:ffi';

import 'package:flutter/material.dart';

class ToggleButton extends StatefulWidget {
  Widget? icon;
  Widget? label;
  final bool? isSelected;
  final Function(bool)? onSelected;

  ToggleButton({
    super.key,
    this.icon,
    this.label,
    this.isSelected,
    this.onSelected,
  }) {
    assert(icon != null || label != null);
  }

  @override
  _ToggleButtonState createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<ToggleButton> {
  bool _isSelected = false;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected ?? false;
  }

  @override
  Widget build(BuildContext context) {
    Color color = _isSelected
        ? Theme.of(context).primaryColor
        : Theme.of(context).buttonTheme.colorScheme!.onPrimary;
    if (_isHovered) {
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
        onTap: () {
          setState(() {
            _isSelected = !_isSelected;
          });
          if (widget.onSelected != null) {
            widget.onSelected!(_isSelected);
          }
        },
        child: Padding(
            padding: EdgeInsets.only(top: 6, bottom: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.icon != null)
                  Padding(
                    padding: EdgeInsets.only(left: 6, right: 6),
                    child: SizedBox(
                      width: 24,
                      height: 24,
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
