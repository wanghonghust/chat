import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final buttonColors = WindowButtonColors(
      iconNormal: brightness == Brightness.light ? Colors.black : Colors.white,
      iconMouseDown:
          brightness == Brightness.light ? Colors.black : Colors.white,
      iconMouseOver:
          brightness == Brightness.light ? Colors.black : Colors.white,
      normal: Colors.transparent,
      mouseOver: brightness == Brightness.light
          ? Colors.black.withOpacity(0.04)
          : Colors.black.withOpacity(0.04),
      mouseDown: brightness == Brightness.light
          ? Colors.black.withOpacity(0.08)
          : Colors.black.withOpacity(0.08),
    );

    final closeButtonColors = WindowButtonColors(
      iconNormal: brightness == Brightness.light ? Colors.black : Colors.white,
      iconMouseDown:
          brightness == Brightness.light ? Colors.black : Colors.white,
      iconMouseOver:
          brightness == Brightness.light ? Colors.black : Colors.white,
      normal: Colors.transparent,
      mouseOver: brightness == Brightness.light
          ? Colors.red
          : Colors.red,
      mouseDown: brightness == Brightness.light
          ? Colors.redAccent
          : Colors.redAccent,
    );
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors,),
        appWindow.isMaximized
            ? RestoreWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              )
            : MaximizeWindowButton(
                colors: buttonColors,
                onPressed: maximizeOrRestore,
              ),
        CloseWindowButton(
          colors: closeButtonColors,
        ),
      ],
    );
  }
}
