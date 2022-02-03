import 'package:logger/logger.dart';

Logger getLogger(String className) {
  return Logger(printer: InternalLogPrinter(className));
}

//LogPrinter implementation
//Log format '[className] Date - {Log.level} - {log.message}'
class InternalLogPrinter extends LogPrinter {
  final String className;
  InternalLogPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    AnsiColor? color = PrettyPrinter.levelColors[event.level];
    return [
      color!(
          // ignore: lines_longer_than_80_chars
          '[$className] ${DateTime.now()} - ${(event.level).toString().toUpperCase().split('.')[1]} - ${event.message}')
    ];
  }
}
