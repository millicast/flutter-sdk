import 'config.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'logger.dart';

// ignore: unused_element
var _logger = getLogger('PeerConnection');
const Map<String, dynamic> webRTCEvents = {};
const String defaultTurnServerLocation = Config.millicastTurnserverLocation;
const Map<String, dynamic> localSDPOptions = {};

class PeerConnection {
  String? sessionDescription;
  String? peer;
  String? peerConnectionStats;

  PeerConnection();

  static void setTurnServerLocation(String url) {}

  static String getTurnServerLocation() {
    return '';
  }

  Future<RTCPeerConnection> getRTCpeer() async {
    return createPeerConnection({});
  }

  void closeRTCPeer() async {}

  getRTCConfiguration(Map<String, dynamic> config) async {}

  getRTCIceServers(String location) async {}

  void setRTCRemoteSDP(Map<String, dynamic> sdp) async {}

  getRTCLocalSDP(dynamic options) async {}

  void addRemoteTrack(String media, List<MediaStream> stream) async {}

  void updateBitrate({num bitrate = 0}) {}

  RTCPeerConnectionState getRTCPeerStatus() {
    return RTCPeerConnectionState.RTCPeerConnectionStateClosed;
  }

  void replaceTrack(MediaStreamTrack mediaStreamTrack) {}

  static getCapabilities(String kind) {}

  getTrucks() {}

  void initStats() {}
  void stopStats() {}

  // ignore: prefer_function_declarations_over_variables
  bool Function(MediaStream mediaStream) isMediaStreamValid =
      (MediaStream mediaStream) {
    return false;
  };

  // ignore: prefer_function_declarations_over_variables
  MediaStream Function(MediaStream mediaStream) getValidMediaStream =
      (MediaStream mediaStream) {
    return mediaStream;
  };

  void Function(RTCPeerConnection instanceClass, RTCPeerConnection peer)
      // ignore: prefer_function_declarations_over_variables
      addPeerEvents =
      (RTCPeerConnection instanceClass, RTCPeerConnection peer) async {};

  void Function(RTCPeerConnection peer, MediaStream mediaStream,
          Map<String, dynamic> options)
      // ignore: prefer_function_declarations_over_variables
      addMediaStreamToPeer = (RTCPeerConnection peer, MediaStream mediaStream,
          Map<String, dynamic> options) {};

  void Function(RTCPeerConnection peer, Map<String, dynamic> options)
      // ignore: prefer_function_declarations_over_variables
      addReceiveTransceivers =
      (RTCPeerConnection peer, Map<String, dynamic> options) {};

  void Function(RTCPeerConnection peer)
      // ignore: prefer_function_declarations_over_variables
      getConnectionState = (RTCPeerConnection peer) {};
}
