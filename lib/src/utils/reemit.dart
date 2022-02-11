import 'package:eventify/eventify.dart';

var eventEmitter = EventEmitter();

void reemit(EventEmitter source, EventEmitter target, List<String> events) {
  var listeners = [];
  void Function(Event, Object?) callback;
  List<void Function(Event, Object?)> callbacks = [];
  for (var event in events) {
    listeners.add(event);
    callback = (event, context) {
      source.emit(
        event.eventName,
        source,
      );
    };
    source.on(event, source, callback);
    callbacks.add(callback);
  }
  for (String event in events) {
    for (callback in callbacks) {
      source.removeListener(event, callback);
    }
  }
}
