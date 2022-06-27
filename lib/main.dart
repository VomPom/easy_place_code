import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_easy_permission/constants.dart';
import 'package:flutter_easy_permission/easy_permissions.dart';
import 'package:flutter_scankit/flutter_scankit.dart';

import 'package:url_launcher/url_launcher.dart';

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
          body: Home()),
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

  String code = "";

  @override
  void initState() {
    super.initState();
    scanKit = FlutterScankit();
    scanKit.addResultListen((val) {
      debugPrint("scanning result:$val");
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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          child: const Text("扫场所码添加"),
          onPressed: () async {
            isCustom = false;
            if (!await FlutterEasyPermission.has(
                perms: _permissions, permsGroup: _permissionGroup)) {
              FlutterEasyPermission.request(
                  perms: _permissions, permsGroup: _permissionGroup);
            } else {
              startScan();
            }
          },
        ),
        const SizedBox(
          width: 50,
        ),
        ElevatedButton(
          child: const Text("打开健康码(随申码)"),
          onPressed: () async {
            isCustom = true;
            if (!await FlutterEasyPermission.has(
                perms: _permissions, permsGroup: _permissionGroup)) {
              FlutterEasyPermission.request(
                  perms: _permissions, permsGroup: _permissionGroup);
            } else {
              _openAliPay('http://qrcode.sh.gov.cn/enterprise/scene');
            }
          },
        )
      ],
    );
  }
}
