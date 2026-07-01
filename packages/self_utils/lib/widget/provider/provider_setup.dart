import 'package:self_utils/global/utils_global.dart';
import 'package:self_utils/widget/provider/provider_model.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

List<SingleChildWidget> providers = <SingleChildWidget>[
  Provider<TextModel>(create: (_) => TextModel()),
];
