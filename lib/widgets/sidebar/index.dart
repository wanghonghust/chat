import 'package:flutter/material.dart';

class SidebarItem {
  final Widget title;
  Key? key;
  final Widget? icon;
  final bool selected;
  final String? route;
  final Function()? onTap;

  SidebarItem({
    this.key,
    required this.title,
    this.icon,
    this.onTap,
    this.selected = false,
    this.route,
  }) {
    key ??= UniqueKey();
  }
}
