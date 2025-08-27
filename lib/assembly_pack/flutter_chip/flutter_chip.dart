import '../../init.dart';

class ChipPageTest extends StatefulWidget {
  const ChipPageTest({Key? key}) : super(key: key);

  @override
  State<ChipPageTest> createState() => _ChipPageTestState();
}

class _ChipPageTestState extends State<ChipPageTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('chip test'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Chip(
              label: const Text('first chip'),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () {
                Log.info('message');
              },
            ),
            Chip(
              avatar: const CircleAvatar(
                child: Text('2'),
              ),
              label: const Text('chip'),
              deleteIcon: const Icon(Icons.close),
              onDeleted: () {
                Log.info('message');
              },
            ),
            /// row里出现长字符串的文本溢出，可以使用expanded组件
            Row(children: const <Widget>[
              // const Text('Lorem ipsum dolor sit amet consectetur adipisicing elit. Perferendis temporibus alias eligendi quas ullam atque numquam repudiandae est minima do'),
              Expanded(
                child: Text(
                    'Lorem ipsum dolor sit amet consectetur adipisicing elit. Perferendis temporibus alias eligendi quas ullam atque numquam repudiandae est minima do'),
              ),
            ])
          ],
        ),
      ),
    );
  }
}
