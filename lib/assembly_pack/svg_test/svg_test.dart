import 'package:flutter_svg/flutter_svg.dart';

import '/../init.dart';

class SvgTestPage extends StatefulWidget {
  const SvgTestPage({Key? key}) : super(key: key);

  @override
  State<SvgTestPage> createState() => _SvgTestPageState();
}

class _SvgTestPageState extends State<SvgTestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          child: SvgPicture.asset('assets/relaxation.svg', width: 200,),
        ),
      ),
    );
  }
}
