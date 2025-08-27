import 'package:self_utils/utils/text_formatter.dart';

import '/../init.dart';

class TextInputTest extends StatefulWidget {
  const TextInputTest({Key? key}) : super(key: key);

  @override
  State<TextInputTest> createState() => _TextInputTestState();
}

class _TextInputTestState extends State<TextInputTest> {
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text input test'),
      ),
      body: Center(
        child: Column(
          children: [
            const Text('money text'),
            TextField(
              inputFormatters: TextInputFormatterHelper.priceInputFormatter(3, decimalMaxLen: 4),
              controller: controller,

            )
          ],
        ),
      ),
    );
  }
}
