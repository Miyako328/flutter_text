import '/../init.dart';

class TextStyleTest extends StatefulWidget {
  const TextStyleTest({Key? key}) : super(key: key);

  @override
  State<TextStyleTest> createState() => _TextStyleTestState();
}

class _TextStyleTestState extends State<TextStyleTest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 50,
              color: Colors.red,
              child: const Text(
                'AgB',
                style: TextStyle(fontSize: 50),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              color: Colors.red,
              child: const Text(
                'AgB',
                style: TextStyle(
                  fontSize: 50,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              color: Colors.red,
              child: const Text(
                'AgB',
                style: TextStyle(fontSize: 50),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 50,
              color: Colors.red,
              child: const Text(
                'AgB',
                style: TextStyle(fontSize: 50),
                strutStyle: StrutStyle(
                  forceStrutHeight: true,
                  fontSize: 50,
                  height: 1,
                  leading: 0
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
