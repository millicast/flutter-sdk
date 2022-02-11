import 'package:eventify/eventify.dart';

var eventEmitter = EventEmitter();

void reemit(EventEmitter source, EventEmitter target, List<String> events) {
  var listeners = [];
  var callbacks = [];
  var callback;
  for (var event in events) {
    listeners.add(event);
    callback = source.on(event, source, (event, context) {
      source.emit(
        event.eventName,
        source,
      );
      callbacks.add(callback);
    });
  }

  for (var event in events) {
    for (var callback in callbacks) {
      source.removeListener(event, callback);
    }
  }
}
