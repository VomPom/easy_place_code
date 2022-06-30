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

import 'components/place_item.dart';

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
            title: const Text('场所码助手'),
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
  String code = "";

  @override
  void initState() {
    initLocalData();
    scanKit = FlutterScankit();
    scanKit.addResultListen((val) {
      debugPrint("scanning result:$val");
      _insertScanData(val);
      _openAliPay(Uri.encodeComponent(val));
      setState(() {
        code = val;
      });
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
      return;
    }
    QRCode qrCode = QRCode(
        id: id,
        description: "汤臣",
        qrCodeResult: scanData,
        createdTime: DateTime.now());
    QrCodeDatabase.instance.create(qrCode);
    print('--julis insert success');
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
    return NotificationListener<CustomNotification>(
      onNotification: (val) {
        initLocalData();
        return true;
      },
      child: SingleChildScrollView(
        child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: AlignmentDirectional.topStart,
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
                              perms: _permissions,
                              permsGroup: _permissionGroup)) {
                            FlutterEasyPermission.request(
                                perms: _permissions,
                                permsGroup: _permissionGroup);
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
                              perms: _permissions,
                              permsGroup: _permissionGroup)) {
                            FlutterEasyPermission.request(
                                perms: _permissions,
                                permsGroup: _permissionGroup);
                          } else {
                            _openAliPay(
                                'http://qrcode.sh.gov.cn/enterprise/scene');
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
                      // ElevatedButton(
                      //   child: const Text("扫场所码"),
                      //   onPressed: () async {
                      //     isCustom = false;
                      //     if (!await FlutterEasyPermission.has(
                      //         perms: _permissions,
                      //         permsGroup: _permissionGroup)) {
                      //       FlutterEasyPermission.request(
                      //           perms: _permissions,
                      //           permsGroup: _permissionGroup);
                      //     } else {
                      //       startScan();
                      //     }
                      //   },
                      // ),
                      // const SizedBox(
                      //   width: 20,
                      // ),
                      // ElevatedButton(
                      //   child: const Text("健康码(随申码)"),
                      //   onPressed: () async {
                      //     isCustom = true;
                      //     if (!await FlutterEasyPermission.has(
                      //         perms: _permissions,
                      //         permsGroup: _permissionGroup)) {
                      //       FlutterEasyPermission.request(
                      //           perms: _permissions,
                      //           permsGroup: _permissionGroup);
                      //     } else {
                      //       _openAliPay(
                      //           'http://qrcode.sh.gov.cn/enterprise/scene');
                      //     }
                      //   },
                      // ),
                      // const SizedBox(
                      //   width: 20,
                      // ),
                      // ElevatedButton(
                      //     child: const Text("存数据"),
                      //     onPressed: () async {
                      //       QRCode qrCode = QRCode(
                      //           id: DateTime.now().hashCode,
                      //           description: "汤臣",
                      //           qrCodeResult: "qrcode",
                      //           createdTime: DateTime.now());
                      //       QrCodeDatabase.instance.create(qrCode);
                      //       QrCodeDatabase.instance
                      //           .readAllQRCode()
                      //           .then((value) => value.forEach((element) {
                      //                 print(
                      //                     '--julis  QrCodeDatabase.instance.readAllQRCode():${element.toJson()}');
                      //               }));
                      //     })
                    ],
                  ),
                ),
                Container(
                  height: double.infinity,
                  margin: const EdgeInsets.only(top: 160),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(6),
                        topRight: Radius.circular(6)),
                  ),
                  child: Column(
                    children: items
                        .asMap()
                        .map<int, Widget>((i, item) =>
                            MapEntry(i, PlaceItem(data: item, index: i)))
                        .values
                        .toList(),
                    // items.map((c) => PlaceItem(data: items[index], index: index)).toList(),
                  )),
              ],
            )),
        ),
    );
  }

  void initLocalData() async {
    items = await QrCodeDatabase.instance.readAllQRCode();
    setState(() {});
    items.forEach((element) =>
    print('julis ${(element as QRCode).description}'));
  }
}
