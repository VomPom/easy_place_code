import 'dart:ffi';

import 'package:easy_place_code/model/qr_code.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:oktoast/oktoast.dart';

import '../data_helper.dart';
import '../utils/notify_modal.dart';

class PlaceItem extends StatefulWidget {
  const PlaceItem({
    Key? key,
    required this.data,
    required this.index,
  }) : super(key: key);

  final QRCode data;
  final int index;

  @override
  State<PlaceItem> createState() => _PlaceItemState();
}

class _PlaceItemState extends State<PlaceItem> {
  final TextEditingController _controller = TextEditingController();
  bool isEdit = false;
  @override
  void initState() {
    _controller.text = widget.data.description;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Slidable(
          key: Key(widget.data.id.toString()),
           endActionPane: ActionPane(
              motion: const StretchMotion(),
              children: [
                SlidableAction(
                  onPressed: (context) {
                    isEdit = true;
                    setState(() {});
                  },
                  backgroundColor: Color(0xFF7BC043),
                  foregroundColor: Colors.white,
                  // icon: Icons.edit,
                  label: '编辑',
                ),
                SlidableAction(
                  onPressed: (context) async {
                    await QrCodeDatabase.instance.delete(widget.data.id!);
                    CustomNotification("reload").dispatch(context);
                  },
                  backgroundColor: const Color.fromARGB(255, 231, 76, 65),
                  foregroundColor: Colors.white,
                  // icon: Icons.delete,
                  label: '删除',
                ),
              ],
            ),
          child: _buildBody(),
        ),
        const Divider(
          color: Color.fromARGB(255, 233, 227, 227),
          height: 0.5,
        )
      ],
    );
  }

  Widget _buildBody() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      decoration: widget.index == 0
          ? const BoxDecoration(
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10.0),
                  topRight: Radius.circular(10.0)),
            )
          : null,
      child: InkWell(
        onTap: () {
          _openAliPay('http://qrcode.sh.gov.cn/enterprise/scene');
        },
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 16),
              child: Row(
                children: [
                  Text(
                    (widget.index + 1).toString(),
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Container(width: 8),
                  if (isEdit)
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        decoration: null,
                        autofocus: true,
                        onSubmitted: (val) async {
                          print(_controller.text);
                          // todo 存数据库
                          await QrCodeDatabase.instance.update(widget.data.copy(description: _controller.text));
                          // _controller.text = '';
                          CustomNotification("reload").dispatch(context);
                          isEdit = false;
                          // setState(() {});
                        },
                      )
                    )
                  else
                    Text(
                      widget.data.description,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                ],
              ),
            ),
          ],
        )),
    );
  }

  void _openAliPay(String qrResult) async {
    String urlStr =
        'alipayqr://platformapi/startapp?saId=10000007&qrcode=$qrResult';
    debugPrint('urlStr:$urlStr');
    Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }
}
