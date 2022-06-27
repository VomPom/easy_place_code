import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_easy_permission/constants.dart';
import 'package:flutter_easy_permission/easy_permissions.dart';
import 'package:flutter_scankit/flutter_scankit.dart';

const _permissions = const [
  Permissions.READ_EXTERNAL_STORAGE,
  Permissions.CAMERA
];

const _permissionGroup = const [PermissionGroup.Camera, PermissionGroup.Photos];

class ScanPageStatefulWidget extends StatefulWidget {
  @override
  _ScanPageStatefulWidgetState createState() => _ScanPageStatefulWidgetState();
}

class _ScanPageStatefulWidgetState extends State<ScanPageStatefulWidget> {
  late bool isCustom;
  late FlutterScankit scanKit;

  String code = "";

  @override
  void initState() {
    super.initState();
    scanKit = FlutterScankit();
    scanKit.addResultListen((val) {
      debugPrint("scanning result:$val");
      setState(() {
        code = val;
      });
    });

    FlutterEasyPermission().addPermissionCallback(
        onGranted: (requestCode, perms, perm) {
          isCustom ? newPage(context) : startScan();
        },
        onDenied: (requestCode, perms, perm, isPermanent) {});
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

  Future<void> newPage(BuildContext context) async {
    var code = await Navigator.of(context)
        .push(MaterialPageRoute(builder: (BuildContext context) {
      return Container();
    }));

    setState(() {
      this.code = code ?? "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(code),
          SizedBox(
            height: 32,
          ),
          ElevatedButton(
            child: Text("Scan code"),
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
          ElevatedButton(
            child: Text("Customized"),
            onPressed: () async {
              isCustom = true;
              if (!await FlutterEasyPermission.has(
                  perms: _permissions, permsGroup: _permissionGroup)) {
                FlutterEasyPermission.request(
                    perms: _permissions, permsGroup: _permissionGroup);
              } else {
                newPage(context);
              }
            },
          )
        ],
      ),
    );
  }
}
