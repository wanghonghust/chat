import 'package:flutter/material.dart';

class SelectWidget extends StatefulWidget {
  final String? value;
  final List<PopupMenuItem<String>> items;
  final Function(String)? onSelected;
  const SelectWidget(
      {super.key, this.value, required this.items, required this.onSelected});
  @override
  _SelectWidgetState createState() => _SelectWidgetState();
}

class _SelectWidgetState extends State<SelectWidget> {
  bool isSelecting = false;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      color: const Color.fromARGB(199, 167, 167, 167),
      borderRadius: BorderRadius.circular(5),
      onSelected: (String value) {
        setState(() {
          isSelecting = false;
        });
        if (widget.onSelected != null) {
          widget.onSelected!(value);
        }
      },
      itemBuilder: (BuildContext context) {
        return widget.items;
      },
      onOpened: () {
        setState(() {
          isSelecting = true;
        });
      },
      onCanceled: () {
        setState(() {
          isSelecting = false;
        });
      },
      child: Container(
          decoration: BoxDecoration(
              color: Theme.of(context).hoverColor,
              borderRadius: BorderRadius.circular(5)),
          padding: EdgeInsets.only(right: 8, left: 8, top: 5, bottom: 5),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(
              widget.value ?? "",
              style: TextStyle(fontSize: 12),
            ),
            Icon(isSelecting ? Icons.arrow_drop_up : Icons.arrow_drop_down,size: 12,)
          ])),
    );
  }
}
