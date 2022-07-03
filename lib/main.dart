import 'dart:ffi';
import 'package:easy_place_code/data_helper.dart';
import 'package:easy_place_code/model/qr_code.dart';
import 'package:easy_place_code/utils/notify_modal.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_easy_permission/constants.dart';
import 'package:flutter_easy_permission/easy_permissions.dart';
import 'package:flutter_scankit/flutter_scankit.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:awesome_dialog/awesome_dialog.dart';

import 'components/place_item.dart';
import 'components/tips_dialog.dart';

void main() {
  runApp(const PlaceCodeHelper());
}

class PlaceCodeHelper extends StatelessWidget {
  const PlaceCodeHelper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('场所码小助手'),
            actions: [TipsDialog()],
          ),
          body: const Home()),
    );
  }
}

const _permissions = [Permissions.READ_EXTERNAL_STORAGE, Permissions.CAMERA];

const _permissionGroup = [PermissionGroup.Camera, PermissionGroup.Photos];

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  HomeState createState() => HomeState();
}

class HomeState extends State<Home> {
  late bool isCustom;
  late FlutterScankit scanKit;
  List items = [];
  dynamic _context = null;
  final TextEditingController _textController = TextEditingController();
  QRCode curQrCode = QRCode(
      id: 0,
      description: "新的场所码",
      qrCodeResult: '',
      createdTime: DateTime.now());

  @override
  void initState() {
    initLocalData();
    scanKit = FlutterScankit();
    scanKit.addResultListen((val) {
      debugPrint("scanning result:$val");
      _insertScanData(val);
      _openAliPay(Uri.encodeComponent(val));
    });

    FlutterEasyPermission().addPermissionCallback(
        onGranted: (requestCode, perms, perm) {
          startScan();
        },
        onDenied: (requestCode, perms, perm, isPermanent) {});
    super.initState();
  }

  void _insertScanData(String scanData) async {
    int id = scanData.hashCode;
    QRCode? readData = await QrCodeDatabase.instance.readQRCode(id);
    if (readData != null) {
      print('object scanData:$scanData readData.dest:${readData.qrCodeResult}');
      return;
    }

    QRCode qrCode = QRCode(
        id: id,
        description: "新的场所码",
        qrCodeResult: scanData,
        createdTime: DateTime.now());
    curQrCode = qrCode;

    QrCodeDatabase.instance.create(qrCode);
    print('--julis insert success:$scanData');
    initLocalData();
    _showCustomDialog(_context);
  }

  void _openAliPay(String qrResult) async {
    String urlStr =
        'alipayqr://platformapi/startapp?saId=10000007&qrcode=$qrResult';
    debugPrint('urlStr:$urlStr');
    Uri url = Uri.parse(urlStr);
    if (!await launchUrl(url)) throw 'Could not launch $url';
  }

  @override
  void dispose() {
    scanKit.dispose();
    super.dispose();
  }

  Future<void> startScan() async {
    try {
      await scanKit.startScan(scanTypes: [ScanTypes.ALL]);
    } on PlatformException {}
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return NotificationListener<CustomNotification>(
      onNotification: (val) {
        initLocalData();
        return true;
      },
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            height: 160,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(color: Colors.blue),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () async {
                    isCustom = false;
                    if (!await FlutterEasyPermission.has(
                        perms: _permissions, permsGroup: _permissionGroup)) {
                      FlutterEasyPermission.request(
                          perms: _permissions, permsGroup: _permissionGroup);
                    } else {
                      startScan();
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "lib/assets/scan.svg",
                        color: Colors.white,
                        height: 48,
                        width: 48,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '扫一扫',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    isCustom = true;
                    if (!await FlutterEasyPermission.has(
                        perms: _permissions, permsGroup: _permissionGroup)) {
                      FlutterEasyPermission.request(
                          perms: _permissions, permsGroup: _permissionGroup);
                    } else {
                      _openAliPay('http://qrcode.sh.gov.cn/enterprise/scene');
                    }
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        "lib/assets/health.svg",
                        color: Colors.white,
                        height: 48,
                        width: 48,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '健康码',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    return PlaceItem(data: items[i], index: i);
                  }))
        ],
      ),
    );
  }

  void initLocalData() async {
    items = await QrCodeDatabase.instance.readAllQRCode();
    setState(() {});
    items.forEach(
        (element) => {print('julis ${(element as QRCode).description}')});
  }

  void _showCustomDialog(context) {
    AwesomeDialog(
        context: context,
        dialogType: DialogType.INFO,
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 76, 140, 175),
          width: 1,
        ),
        width: 380,
        buttonsBorderRadius: const BorderRadius.all(
          Radius.circular(2),
        ),
        btnCancelText: '取消',
        btnOkColor: Colors.blue,
        btnOkText: '确认',
        btnCancelColor: const Color.fromARGB(255, 222, 226, 230),
        headerAnimationLoop: false,
        animType: AnimType.BOTTOMSLIDE,
        // title: '提示',
        // desc: '一个1级bug向你发起挑衅，是否迎战？',
        showCloseIcon: true,
        btnCancelOnPress: () {},
        btnOkOnPress: () async {
          await QrCodeDatabase.instance
              .update(curQrCode.copy(description: _textController.text));
          initLocalData();
        },
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '说的就是时间发货看对方国家的法规和深刻的个黄金分割复古杨贵妃i一个vu时光如',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(
                  height: 8,
                ),
                TextField(
                  autofocus: true,
                  controller: _textController,
                  decoration: InputDecoration(
                      hintText: '请输入场所码位置标记',
                      hintStyle: TextStyle(color: Colors.grey)),
                )
              ]),
        )).show();
  }
}
