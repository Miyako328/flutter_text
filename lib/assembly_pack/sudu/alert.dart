import '../../init.dart';
import 'style.dart';

class AlertGameOver extends StatelessWidget {
  final int time;
  static bool newGame = false;
  static bool restartGame = false;

  const AlertGameOver({required this.time});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Styles.white,
      title: Text(
        '游戏结束',
        style: TextStyle(color: Styles.darkGrey),
      ),
      content: Text(
        '恭喜通关该难度！用时${DateTimeHelper.secToMSTime(time)}',
        style: TextStyle(color: Styles.darkGrey),
      ),
      actions: [
        TextButton(
          style: ButtonStyle(
              foregroundColor:
                  WidgetStateProperty.all<Color>(Styles.primaryColor)),
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('返回'),
        ),
        TextButton(
          style: ButtonStyle(
              foregroundColor:
                  WidgetStateProperty.all<Color>(Styles.primaryColor)),
          onPressed: () {
            Navigator.pop(context);
            restartGame = true;
          },
          child: const Text('重新开始'),
        ),
        TextButton(
          style: ButtonStyle(
              foregroundColor:
                  WidgetStateProperty.all<Color>(Styles.primaryColor)),
          onPressed: () {
            Navigator.pop(context);
            newGame = true;
          },
          child: const Text('新游戏'),
        ),
      ],
    );
  }
}

class AlertNumbersState extends StatefulWidget {
  @override
  AlertNumbers createState() => AlertNumbers();

  static int get number {
    return AlertNumbers.number;
  }

  static set number(int number) {
    AlertNumbers.number = number;
  }
}

class AlertNumbers extends State<AlertNumbersState> {
  static int number = 0;
  int numberSelected = 0;
  static final List<int> numberList1 = <int>[1, 2, 3];
  static final List<int> numberList2 = <int>[4, 5, 6];
  static final List<int> numberList3 = <int>[7, 8, 9];

  List<SizedBox> createButtons(List<int> numberList) {
    return <SizedBox>[
      for (int numbers in numberList)
        SizedBox(
          width: 38,
          height: 38,
          child: TextButton(
            onPressed: () => {
              setState(() {
                numberSelected = numbers;
                number = numberSelected;
                Navigator.pop(context);
              })
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(Styles.white),
              foregroundColor:
                  WidgetStateProperty.all<Color>(Styles.primaryColor),
              shape: WidgetStateProperty.all<OutlinedBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              )),
              side: WidgetStateProperty.all<BorderSide>(BorderSide(
                color: Styles.darkGrey,
                width: 1,
                style: BorderStyle.solid,
              )),
            ),
            child: Text(
              numbers.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        )
    ];
  }

  List<Row> createRows() {
    final List<List<int>> numberLists = [numberList1, numberList2, numberList3];
    final List<Row> rowList = List<Row>.filled(3, const Row());
    for (int i = 0; i <= 2; i++) {
      rowList[i] = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: createButtons(numberLists[i]),
      );
    }
    return rowList;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      backgroundColor: Styles.white,
      title: Center(
          child: Text(
        'Choose a Number',
        style: TextStyle(color: Styles.darkGrey),
      )),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: createRows(),
      ),
    );
  }
}
