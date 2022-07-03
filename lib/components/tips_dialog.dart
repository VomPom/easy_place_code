import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';

class TipsDialog extends StatelessWidget {
  const TipsDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showTipsDialog(context);
      },
      child: Padding(
        padding: const EdgeInsets.only(right: 8),
        child: SvgPicture.asset(
          "lib/assets/tips.svg",
          color: Colors.white,
          height: 32,
          width: 32,
        ),
      ),
    );
  }

  void _showTipsDialog(BuildContext context) {
    AwesomeDialog(
      context: context,
      headerAnimationLoop: true,
      animType: AnimType.BOTTOMSLIDE,
      body: Container(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [
              Text(
                '说的就是时间发货看对方国家的法规和深刻的个黄金分割复古杨贵妃i一个vu时光如',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ]),
      ),
    ).show();
  }
}
