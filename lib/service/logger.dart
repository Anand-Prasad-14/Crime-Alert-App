import 'package:logger/logger.dart';
import 'package:stack_trace/stack_trace.dart';

final logger = () => Logger(printer: CustomPrinter.instance, level: Level.verbose);

class CustomPrinter extends LogPrinter {
  static CustomPrinter _customPrinter = CustomPrinter();
  CustomPrinter();
  static CustomPrinter get instance {
    if (_customPrinter != null) {
      return _customPrinter;
    } else {
      _customPrinter = CustomPrinter();
      return _customPrinter;
    }
  }

  String trace = Trace.current().frames[2].member.toString();
  String? clName;
  String? mlName;
  @override
  List<String> log(LogEvent event) {
    int index = trace.indexOf(".");
    if (index != -1) {
      clName = trace.substring(0,index).trim();
      mlName = trace.substring(index + 1).trim();
    } else {
      clName = trace;
    }
    final color = PrettyPrinter.defaultLevelColors[event.level];
    final message = event.message;
    final String cName = '======= $clName =======';
    final String mName = '----- $mlName -----';
    final String end = '<' * 30;
    return [color!('\n$cName\n$mName\n\n$message\n\n$end\n')];
  }
}