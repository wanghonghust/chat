//  This file is automatically generated. DO NOT EDIT, all your changes would be lost.
//  https://pub.dartlang.org/packages/iconfont_convert

import 'package:flutter/material.dart';

class IconFont {
  static const String _family = 'IconFont';
  
  IconFont._();
  
  static const IconData designer_drawer_set_up = IconData(0xe609, fontFamily: _family); // designer-drawer-set-up
}

class _PreviewIcon {
  const _PreviewIcon(this.icon, this.name, this.propName);

  final IconData icon;
  final String name;
  final String propName;
}

class IconFontPreview extends StatelessWidget {
  const IconFontPreview({Key? key}) : super(key: key);

  static const iconList = <_PreviewIcon>[
    _PreviewIcon(IconFont.designer_drawer_set_up, "designer_drawer_set_up", "designer-drawer-set-up"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IconFont'),
      ),
      body: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 4,
        children: iconList.map((e) {
          return InkWell(
            onTap: () {
              //
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: Icon(e.icon),
                ),
                Text(e.name, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 1),
                Text(e.propName, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis, maxLines: 1),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
