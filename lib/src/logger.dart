import 'package:logger/logger.dart';

Logger getLogger(String className) {
  var output = MultiOutput([memory, ConsoleOutput()]);
  return Logger(output: output, printer: InternalLogPrinter(className));
}

BufferMemoryOutput memory = BufferMemoryOutput(bufferSize: maxLogHistorySize);
const defaultLogHistorySize = 10000;
int maxLogHistorySize = defaultLogHistorySize;
List<String> history = [];

/// LogPrinter implementation
/// Log format '[className] Date - {Log.level} - {log.message}'
class InternalLogPrinter extends LogPrinter {
  final String className;
  InternalLogPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    AnsiColor? color = PrettyPrinter.levelColors[event.level];
    var logResult = color!(
        // ignore: lines_longer_than_80_chars
        '[$className] ${DateTime.now()} - ${(event.level).toString().toUpperCase().split('.')[1]} - ${event.message}');
    OutputEvent output = OutputEvent(event, [logResult]);
    memory.output(output);
    return [logResult];
  }
}

class BufferMemoryOutput extends MemoryOutput {
  @override
  // ignore: overridden_fields
  int bufferSize;
  // ignore: lines_longer_than_80_chars
  BufferMemoryOutput({required this.bufferSize, LogOutput? secondOutput})
      : super(bufferSize: bufferSize, secondOutput: secondOutput);

  void setBufferSize(int val) {
    bufferSize = val;
    if (buffer.length > bufferSize) {
      while (buffer.length > bufferSize) {
        buffer.removeFirst();
      }
    }
  }

  List<String> getBuffer() {
    history = [];
    for (var element in memory.buffer) {
      {
        history.add(element.lines.first.toString());
      }
    }
    return history;
  }

  int getBufferMaxSize() {
    return bufferSize;
  }

  @override
  void output(OutputEvent event) {
    if (buffer.length >= bufferSize) {
      while (buffer.length >= bufferSize) {
        buffer.removeFirst();
      }
    }
    buffer.addAll([event]);
    secondOutput?.output(event);
  }
}
