// import 'package:dynamic_widget/dynamic_widget/basic/dynamic_widget_json_exportor.dart';
// import 'package:flutter/material.dart';
// import 'package:self_utils/utils/log_utils.dart';
//
// class JsonWidgetPage extends StatefulWidget {
//   const JsonWidgetPage({Key? key}) : super(key: key);
//
//   @override
//   State<JsonWidgetPage> createState() => _JsonWidgetPageState();
// }
//
// class _JsonWidgetPageState extends State<JsonWidgetPage> {
//   GlobalKey key = GlobalKey();
//   bool value = false;
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('export example'),
//       ),
//       body: Builder(
//         builder: (BuildContext context) => Column(
//           children: [
//             Expanded(
//               child: Container(
//                 child: DynamicWidgetJsonExportor(
//                   key: key,
//                   child: Container(
//                     child: Text(
//                       'Widget to json text',
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                           color: value == true ? Colors.blue : Colors.black,
//                           fontSize: 20),
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//             ElevatedButton(
//               child: const Text('Export'),
//               onPressed: () {
//                 final DynamicWidgetJsonExportor exportor =
//                     key.currentWidget as DynamicWidgetJsonExportor;
//                 final String exportJsonString = exportor.exportJsonString();
//                 Log.info(exportJsonString);
//               },
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
