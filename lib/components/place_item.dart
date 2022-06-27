import 'package:flutter/material.dart';

class PlaceItem extends StatefulWidget {
  const PlaceItem({
    Key? key,
    required this.data,
    required this.index,
  }) : super(key: key);

  final Map data;
  final int index;

  @override
  State<PlaceItem> createState() => _PlaceItemState();
}

class _PlaceItemState extends State<PlaceItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 60,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration:
      widget.index == 0 ?
        const BoxDecoration(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), topRight: Radius.circular(10.0)),
        ): null,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
            child: Row(
              children: [
                Text(
                  (widget.index + 1).toString(),
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
                Container(width: 8),
                Text(
                  widget.data['title'],
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            color: Color.fromARGB(255, 233, 227, 227),
            height: 0.5,
          )
        ],
      )
    );
  }
}
