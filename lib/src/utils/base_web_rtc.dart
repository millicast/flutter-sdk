import '../peer_connection.dart';

const num maxReconnectionInterval = 32000;
const num baseInterval = 1000;

class BaseWebRTC {
  String streamName;
  Function tokenGenerator;
  bool autoReconnect;
  Object loggerInstance;
  String? signaling;
  PeerConnection? webRTCPeer;
  num? reconnectionInterval;
  bool? alreadyDisconnected;
  bool? firstReconnection;
  Map<String, dynamic>? options;

  BaseWebRTC({
    required this.streamName,
    required this.tokenGenerator,
    required this.autoReconnect,
    required this.loggerInstance,
    this.signaling,
    this.reconnectionInterval = baseInterval,
    this.alreadyDisconnected = false,
    this.firstReconnection = true,
    this.options,
    this.webRTCPeer,
  }) {
    webRTCPeer = PeerConnection();
  }

  Future<Object>? getRTCPeerConnection() {
    return webRTCPeer?.getRTCpeer();
  }

  @override
  String toString() {
    return 'BaseWebRTC(streamName: $streamName, tokenGenerator: $tokenGenerator, autoReconnect: $autoReconnect, loggerInstance: $loggerInstance, signaling: $signaling, webRTCPeer: $webRTCPeer, reconnectionInterval: $reconnectionInterval, alreadyDisconnected: $alreadyDisconnected, firstReconnection: $firstReconnection, options: $options)';
  }
}
