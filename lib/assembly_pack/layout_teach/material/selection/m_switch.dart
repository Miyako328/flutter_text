import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MSwitch extends StatelessWidget {
  const MSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(useMaterial3: true).copyWith(
        // Use the ambient CupertinoThemeData to style all widgets which would
        // otherwise use iOS defaults.
        cupertinoOverrideTheme: const CupertinoThemeData(applyThemeToAll: true),
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Switch Sample')),
        body: const Center(
          child: Column(
            children: [
              SwitchExample(),
              SizedBox(
                height: 5,
              ),
              SwitchExampleTwo()
            ],
          ),
        ),
      ),
    );
  }
}

class SwitchExample extends StatefulWidget {
  const SwitchExample({super.key});

  @override
  State<SwitchExample> createState() => _SwitchExampleState();
}

class _SwitchExampleState extends State<SwitchExample> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Switch.adaptive(
          value: light,
          onChanged: (bool value) {
            setState(() {
              light = value;
            });
          },
        ),
        Switch.adaptive(
          // Don't use the ambient CupertinoThemeData to style this switch.
          applyCupertinoTheme: false,
          value: light,
          onChanged: (bool value) {
            setState(() {
              light = value;
            });
          },
        ),
      ],
    );
  }
}

class SwitchExampleTwo extends StatefulWidget {
  const SwitchExampleTwo({super.key});

  @override
  State<SwitchExampleTwo> createState() => _SwitchExampleTwoState();
}

class _SwitchExampleTwoState extends State<SwitchExampleTwo> {
  bool light = true;

  @override
  Widget build(BuildContext context) {
    final WidgetStateProperty<Color?> trackColor =
        WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        // Track color when the switch is selected.
        if (states.contains(WidgetState.selected)) {
          return Colors.amber;
        }
        // Otherwise return null to set default track color
        // for remaining states such as when the switch is
        // hovered, focused, or disabled.
        return null;
      },
    );
    final WidgetStateProperty<Color?> overlayColor =
        WidgetStateProperty.resolveWith<Color?>(
      (Set<WidgetState> states) {
        // Material color when switch is selected.
        if (states.contains(WidgetState.selected)) {
          return Colors.amber.withValues(alpha: 0.54);
        }
        // Material color when switch is disabled.
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.shade400;
        }
        // Otherwise return null to set default material color
        // for remaining states such as when the switch is
        // hovered, or focused.
        return null;
      },
    );

    return Switch(
      // This bool value toggles the switch.
      value: light,
      overlayColor: overlayColor,
      trackColor: trackColor,
      thumbColor: const WidgetStatePropertyAll<Color>(Colors.black),
      onChanged: (bool value) {
        // This is called when the user toggles the switch.
        setState(() {
          light = value;
        });
      },
    );
  }
}
