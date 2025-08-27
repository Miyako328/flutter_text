import 'package:flutter/material.dart';

class StepperDemo extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: HorizontalStepper(),
    );
  }
}

//水平步骤条
class HorizontalStepper extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => HorizontalStepperState();
}

class HorizontalStepperState extends State<HorizontalStepper> {
  var _horStep = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stepper(
        type: StepperType.horizontal,
        currentStep: _horStep,
          onStepTapped: (step) {
          setState(() {
            _horStep = step;
          });
          },
          steps: [
            Step(
                isActive: _horStep == 0 ? true : false,
                title: Text('Step 标题一'),
                content: Container(
                    color: Colors.orangeAccent.withOpacity(0.4),
                    child: Text('Step 内容一'))),
            Step(
                isActive: _horStep == 1 ? true : false,
                title: Text('Step 标题二'),
                content: Container(
                    color: Colors.blueAccent.withOpacity(0.4),
                    child: Text('Step 内容二'))),
            Step(
                isActive: _horStep == 2 ? true : false,
                title: Text('Step 标题三'),
                content: Container(
                    color: Colors.purple.withOpacity(0.4),
                    child: Text('Step 内容三')))
          ]
      ),
    );
  }
}

//垂直步骤条
class StepperBody extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => StepperBodyState();
}

class StepperBodyState extends State<StepperBody> {
  var _curStep = 0;

  Widget build(BuildContext context) {
    return Container(
      child: Stepper(
          currentStep: _curStep,
          onStepTapped: (step) {
            setState(() {
              _curStep = step;
            });
          },
          steps: [
            Step(
                isActive: _curStep == 0 ? true : false,
                title: Text('Step 标题一'),
                content: Container(
                    color: Colors.orangeAccent.withOpacity(0.4),
                    child: Text('Step 内容一'))),
            Step(
                isActive: _curStep == 1 ? true : false,
                title: Text('Step 标题二'),
                content: Container(
                    color: Colors.blueAccent.withOpacity(0.4),
                    child: Text('Step 内容二'))),
            Step(
                isActive: _curStep == 2 ? true : false,
                title: Text('Step 标题三'),
                content: Container(
                    color: Colors.purple.withOpacity(0.4),
                    child: Text('Step 内容三')))
          ]),
    );
  }
}
