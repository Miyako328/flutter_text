import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class GetPackageWidget extends StatefulWidget {
  @override
  _GetPackageState createState() => _GetPackageState();
}

class _GetPackageState extends State<GetPackageWidget> {
  late PackageInfo packageInfo;

  @override
  void initState() {
    super.initState();
    getPackage();
  }

  //获取包版本
  void getPackage() async {
    packageInfo = await PackageInfo.fromPlatform();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
            'appName: ${packageInfo.appName}  packageName: ${packageInfo.packageName}  version: ${packageInfo.version}  buildNumber: ${packageInfo.buildNumber}  '),
      ),
    );
  }
}
