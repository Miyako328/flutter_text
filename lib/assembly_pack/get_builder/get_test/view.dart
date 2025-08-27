import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'logic.dart';

class GetTestPage extends StatelessWidget {
  GetTestPage({Key? key}) : super(key: key);

  final GetTestLogic logic = Get.put(GetTestLogic(), );

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
