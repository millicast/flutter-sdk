import 'package:logger/logger.dart';

import '../peer_connection.dart';

const num maxReconnectionInterval = 32000;
const num baseInterval = 1000;

class BaseWebRTC {
  String streamName;
  Function tokenGenerator;
  bool autoReconnect;
  Logger logger;
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
    required this.logger,
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
    // ignore: lines_longer_than_80_chars
    return 'BaseWebRTC(streamName: $streamName, tokenGenerator: $tokenGenerator, autoReconnect: $autoReconnect, loggerInstance: $logger, signaling: $signaling, webRTCPeer: $webRTCPeer, reconnectionInterval: $reconnectionInterval, alreadyDisconnected: $alreadyDisconnected, firstReconnection: $firstReconnection, options: $options)';
  }
}
