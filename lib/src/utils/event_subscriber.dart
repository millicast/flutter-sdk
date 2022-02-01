import 'package:web_socket_channel/web_socket_channel.dart';

class EventSubscriber {
  WebSocketChannel? webSocket;
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
