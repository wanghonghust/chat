import 'package:chat/widgets/custom_tab/index.dart';
import 'package:flutter/material.dart';

class CustomTabController extends ChangeNotifier {
  // 当前选中的索引
  int selectedIndex;
  // TabItem列表
  List<TabItem> items;

  CustomTabController({required this.selectedIndex, required this.items});

  List<Widget> getContents() {
    return items.map((item) => item.body).toList();
  }

  // 切换Tab
  void changeTab(int index) {
    selectedIndex = index;
    notifyListeners();
  }

  void addTab(TabItem item) {
    items.add(item);
    selectedIndex = items.length - 1;
    notifyListeners();
  }

  TabItem? removeTab(int index) {
    if (index >= 0 && index < items.length) {
      var item = items.removeAt(index);
      if (items.isEmpty) {
        selectedIndex = -1;
        notifyListeners();
        return item;
      }
      if (index <= selectedIndex) {
        selectedIndex = selectedIndex - 1;
      }else{
        selectedIndex = selectedIndex;
      }
      notifyListeners();
      return item;
    }
    notifyListeners();
    return null;
  }
}
