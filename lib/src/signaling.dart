import 'package:web_socket_channel/web_socket_channel.dart';
import 'logger.dart';

var _logger = getLogger('Signaling');
const Map<String, dynamic> signalingEvents = {};
const Map<String, dynamic> videoCodec = {};
const Map<String, dynamic> audioCodec = {};
const Map<String, dynamic> options = {
  'streamName': null,
  'url': 'ws://localhost:8080/'
};

class Signaling {
  String? streamName;
  String? wsUrl;
  WebSocketChannel? webSocket;
  String? transactionManager;

  Signaling({Map<String, dynamic> options = options}) {
    streamName = options['streamName'];
    wsUrl = options['url'];
  }

  void connect() async {}
  void close() {}
  Future<String> subscribe(String sdp, bool options, String? pinnedSourceId,
      List<String>? excludedSourceIds) async {
    return '';
  }

  Future<String> publish(String sdp, bool? record, String? sourceId) async {
    return '';
  }

  Future<String> cmd(String cmd, Object data) async {
    return '';
  }

  Map<String, dynamic> getSubscribeOptions(Object options,
      String legacyPinnedSourceId, String legacyExcludedSourceIds) {
    return {};
  }

  Map<String, dynamic> getPublishOptions(
      Object options, String legacyRecord, String legacySourceId) {
    return {};
  }
}
