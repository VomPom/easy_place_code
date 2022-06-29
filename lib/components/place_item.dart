import 'package:easy_place_code/model/qr_code.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
  @override
  Widget build(BuildContext context) {
    return Container(
      // height: 60,
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
                      widget.data.description,
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
