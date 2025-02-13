import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:chat/src/data_provider/index.dart';
import 'package:chat/src/pages/settings/controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WindowButtons extends StatefulWidget {
  const WindowButtons({super.key});

  @override
  State<WindowButtons> createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  ThemeNotifier? themeNotifier;
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  void didChangeDependencies() {
    themeNotifier = Provider.of<ThemeNotifier>(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    final buttonColors = WindowButtonColors(
      iconNormal: themeNotifier!.isDarkMode ? Colors.white : Colors.black,
      iconMouseDown: themeNotifier!.isDarkMode ? Colors.white : Colors.black,
      iconMouseOver:themeNotifier!.isDarkMode ? Colors.white : Colors.black,
      normal: Colors.transparent,
      mouseOver: themeNotifier!.isDarkMode ? Colors.white.withAlpha(20) : Colors.black.withAlpha(20),
      mouseDown: themeNotifier!.isDarkMode ? Colors.white.withAlpha(40): Colors.black.withAlpha(40),
    );

    final closeButtonColors = WindowButtonColors(
      iconNormal: brightness == Brightness.light ? Colors.black : Colors.white,
      iconMouseDown:
          brightness == Brightness.light ? Colors.black : Colors.white,
      iconMouseOver:
          brightness == Brightness.light ? Colors.black : Colors.white,
      normal: Colors.transparent,
      mouseOver: brightness == Brightness.light ? Colors.red : Colors.red,
      mouseDown:
          brightness == Brightness.light ? Colors.redAccent : Colors.redAccent,
    );
    return Row(
      children: [
        MinimizeWindowButton(
          colors: buttonColors,
        ),
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
