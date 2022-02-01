import 'dart:io';

class EventSubscriber {
  WebSocket? webSocket;
  String eventsLocation;

  EventSubscriber({
    this.webSocket,
    required this.eventsLocation,
  });

  void subscribe(Object topicRequest) {}
  initializeHandshake() async {}

  Object handleHandshakeResponse(String message) {
    return '';
  }

  Object parseSignalRMessage(String message) {
    return '';
  }

  void close() {}
}
