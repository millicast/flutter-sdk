// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';

import 'package:eventify/eventify.dart';
import 'package:millicast_flutter_sdk/src/utils/sdp_parser.dart';

import 'config.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'logger.dart';
import 'package:http/http.dart' as http;

// ignore: unused_element
var _logger = getLogger('PeerConnection');
const Map<String, dynamic> webRTCEvents = {
  'track': 'track',
  'connectionStateChange': 'connectionStateChange'
};
const Map<String, dynamic> localSDPOptions = {
  'stereo': false,
  'mediaStream': null,
  'codec': 'h264',
  'simulcast': false,
  'scalabilityMode': null,
  'disableAudio': false,
  'disableVideo': false,
  'setSDPToPeer': true,
};

String defaultTurnServerLocation = Config.millicastTurnserverLocation;
String turnServerLocation = defaultTurnServerLocation;

// ignore: lines_longer_than_80_chars, lines_longer_than_80_chars
class PeerConnection extends EventEmitter {
  RTCSessionDescription? sessionDescription;
  RTCPeerConnection? peer;
  String? peerConnectionStats;

  PeerConnection() : super();
  static void setTurnServerLocation(String url) {
    turnServerLocation = url;
  }

  static String getTurnServerLocation() {
    return '';
  }

  Future<RTCPeerConnection> getRTCpeer() async {
    return createPeerConnection({});
  }

  void closeRTCPeer() async {}

  /// Instance new RTCPeerConnection.
  ///
  /// [config] - Peer configuration.
  ///
  createRTCPeer([Map<String, dynamic>? config]) async {
    _logger.i('Creating new RTCPeerConnection');
    _logger.d('RTC configuration provided by user: ');
    config = await getRTCConfiguration(config);
    peer = await instanceRTCPeerConnection(this, config);
  }

  // ignore: lines_longer_than_80_chars
  /// Get default RTC configuration with ICE servers from Milicast signaling server and merge it with the user configuration provided. User configuration has priority over defaults.
  ///
  /// [config] - Options to configure the new RTCPeerConnection.
  /// [Returns [Future<Map<String, dynamic>>] object which represents the RTCConfiguration.

  getRTCConfiguration(Map<String, dynamic>? config) async {
    _logger.i('Getting RTC configuration');
    Map<String, dynamic> configParsed = config ?? {};
    configParsed['iceServers'] =
        configParsed['iceServers'] ?? await getRTCIceServers();
    _logger.d('parseconfig $configParsed');
    return configParsed;
  }

  /// Get Ice servers from a Millicast signaling server.
  ///
  ///  [Future] object which represents a list of Ice servers.
  getRTCIceServers({String? location}) async {
    location = location ?? turnServerLocation;
    _logger.i('Getting RTC ICE servers');
    _logger.d('RTC ICE servers request location: $location');
    List<dynamic> iceServer = [];

    try {
      http.Response data = await http.put(Uri.parse(location));
      _logger.d('RTC ICE servers response: $data');
      if (jsonDecode(data.body)['s'] == 'ok') {
        // call returns old format, this updates URL to URLS in credentials path.
        for (Map credentials in jsonDecode(data.body)['v']['iceServers']) {
          var url = credentials['url'];
          if (url.toString().isNotEmpty) {
            credentials['urls'] = url;
            credentials.remove('url');
          }

          iceServer.add(credentials);
        }
        _logger.i('RTC ICE servers successfully obtained.');
      }
    } catch (e) {
      _logger.e('Error while getting RTC ICE servers: $e');
    }
    return iceServer;
  }

  void setRTCRemoteSDP(String sdp) async {
    _logger.i('Setting RTC Remote SDP');
    try {
      await peer?.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
      _logger.i('RTC Remote SDP was set successfully.');
      _logger.d('RTC Remote SDP new value: $sdp');
    } catch (e) {
      _logger.e('Error while setting RTC Remote SDP: $e');
      rethrow;
    }
  }

  ///  Get the SDP modified depending the options. Optionally set the SDP information to local peer.
  ///
  ///   [Object] options
  ///   [bool] options.stereo - True to modify SDP for support stereo. Otherwise False.
  ///   [bool] options.dtx - True to modify SDP for supporting dtx in opus. Otherwise False.*
  ///   [MediaStream|Array<MediaStreamTrack>] options.mediaStream - MediaStream to offer in a stream. This object must have
  ///  1 audio track and 1 video track, or at least one of them. Alternative you can provide both tracks in an array.
  ///   [VideCodec] options.codec - Selected codec for support simulcast.
  ///   [String] options.scalabilityMode - Selected scalability mode. You can get the available capabilities using  method.
  ///  **Only available in Google Chrome.**
  ///  *[bool] options.absCaptureTime - True to modify SDP for supporting absolute capture time header extension. Otherwise False.
  ///   [bool] options.dependencyDescriptor - True to modify SDP for supporting aom dependency descriptor header extension. Otherwise False.
  ///   [bool] options.disableAudio - True to not support audio.
  ///   [bool] options.disableVideo - True to not support video.
  ///   [bool] options.setSDPToPeer - True to set the SDP to local peer.
  ///   Returns [Future<String>] Promise object which represents the SDP information of the created offer.
  ///

  Future<String?> getRTCLocalSDP(
      {Map<String, dynamic> options = localSDPOptions}) async {
    _logger.i('Getting RTC Local SDP');
    options = {...localSDPOptions, ...options};

    MediaStream? mediaStream =
        await getValidMediaStream(options['mediaStream']);
    if (mediaStream != null) {
      addMediaStreamToPeer(peer, mediaStream, options);
    } else {
      addReceiveTransceivers(peer, options);
    }

    _logger.i('Creating peer offer');
    _logger.i('my peer $peer');
    RTCSessionDescription? response = await peer?.createOffer();
    _logger.i('Peer offer created');
    _logger.d('Peer offer response: ${response?.sdp}');
    sessionDescription = response;

    // if (!options['disableAudio']) {
    //   if (options['stereo']) {
    //     desc.sdp = SdpParser.setStereo(desc.sdp);
    //   }
    //   if (options['dtx']) {
    //     desc.sdp = SdpParser.setDTX(desc.sdp);
    //   }
    //   desc.sdp = SdpParser.setMultiopus(desc.sdp, mediaStream);
    // }
    // if (!options['disableVideo'] && options['simulcast']) {
    //   desc.sdp = SdpParser.setSimulcast(desc.sdp, options['codec']);
    // }
    // if (options['absCaptureTime']) {
    //   desc.sdp = SdpParser.setAbsoluteCaptureTime(desc.sdp);
    // }
    // if (options['dependencyDescriptor']) {
    //   desc.sdp = SdpParser.setDependencyDescriptor(desc.sdp);
    // }
    if (options['setSDPToPeer']) {
      await peer?.setLocalDescription(sessionDescription!);
      _logger.i('Peer local description set');
    }
    return sessionDescription?.sdp;
  }

  void addRemoteTrack(String media, List<MediaStream> stream) async {}

  void updateBitrate({num bitrate = 0}) {}

  String? getRTCPeerStatus() {
    _logger.i('Getting RTC peer status');
    if (peer == null) {
      return null;
    }
    String connectionState = getConnectionState(peer!);
    _logger.i('RTC peer status getted, value: $connectionState');
    return connectionState;
  }

  void replaceTrack(MediaStreamTrack mediaStreamTrack) {}

  static getCapabilities(String kind) {}

  getTrucks() {}

  void initStats() {}
  void stopStats() {}

  bool isMediaStreamValid(MediaStream mediaStream) {
    return mediaStream.getAudioTracks().length <= 1 &&
        mediaStream.getVideoTracks().length <= 1;
  }

  getValidMediaStream(mediaStream) async {
    if (mediaStream == null) {
      return null;
    }

    if (isMediaStreamValid(mediaStream) && mediaStream is MediaStream) {
      return mediaStream;
    } else if (mediaStream is! MediaStream) {
      _logger.i('Creating MediaStream to add received tracks.');
      MediaStream stream = await createLocalMediaStream('myStream');
      mediaStream.getTracks().forEach((track) {
        stream.addTrack(track);
      });

      if (isMediaStreamValid(stream)) {
        return stream;
      }
    }
  }

  /// Emits peer events.
  ///
  /// instanceClass - PeerConnection instance.
  /// [RTCPeerConnection] peer - Peer instance.
  ///  PeerConnection#track
  ///  PeerConnection#connectionStateChange
  ///
  void addPeerEvents(PeerConnection instanceClass, RTCPeerConnection peer) {
    peer.onTrack = (event) async {
      _logger.i('New track from peer.');
      _logger.d('Track event value: $event');

      // Listen for remote tracks events for resolving pending addRemoteTrack calls.
      // TO DO
      // if (event.transceiver != null) {}
      // ;

      instanceClass.emit(webRTCEvents['track'], event);
    };
    if (peer.connectionState != null) {
      peer.onConnectionState = (event) {
        _logger.i('Peer connection state change: ${peer.connectionState}');
        instanceClass.emit(
            webRTCEvents['connectionStateChange'], peer.iceConnectionState);
      };
    } else {
      peer.onIceConnectionState = (RTCIceConnectionState state) {
        _logger.i(
            'Peer ICE connection state change: ', peer.iceConnectionState);

        ///
        ///@fires PeerConnection#connectionStateChange
        ///
        instanceClass.emit(
            webRTCEvents['connectionStateChange'], peer.iceConnectionState);
      };
    }

    peer.onRenegotiationNeeded = () async {
      if (peer.getConfiguration.isEmpty) {
        return;
      }
      _logger.i('Peer onnegotiationneeded, updating local description');
      RTCSessionDescription offer = await peer.createOffer();
      _logger.i('Peer onnegotiationneeded, got local offer ${offer.sdp}');
      peer.setLocalDescription(offer);
      peer.getRemoteDescription().then((value) {
        String? sdp = SdpParser.renegotiate(offer.sdp, value?.sdp);
        _logger.i('Peer onnegotiationneeded, updating remote description', sdp);

        peer.setRemoteDescription(RTCSessionDescription(sdp, 'answer'));
        _logger.i('Peer onnegotiationneeded, renegotiation done');
      });
    };
  }

  void addMediaStreamToPeer(RTCPeerConnection? peer, MediaStream? mediaStream,
      Map<String, dynamic> options) {
    _logger.i('Adding mediaStream tracks to RTCPeerConnection');

    mediaStream?.getTracks().forEach((track) {
      RTCRtpTransceiverInit initOptions = RTCRtpTransceiverInit();
      if (track.kind == 'audio') {
        initOptions = RTCRtpTransceiverInit(
            direction: (options['disableAudio']
                ? TransceiverDirection.SendOnly
                : TransceiverDirection.Inactive),
            streams: [mediaStream]);
      }
      if (track.kind == 'video') {
        initOptions = RTCRtpTransceiverInit(
            direction: (options['disableVideo']
                ? TransceiverDirection.SendOnly
                : TransceiverDirection.Inactive),
            streams: [mediaStream]);
      }
      peer?.addTransceiver(
          kind: (track.kind == 'audio')
              ? RTCRtpMediaType.RTCRtpMediaTypeAudio
              : RTCRtpMediaType.RTCRtpMediaTypeVideo,
          init: initOptions);

      _logger.i(
          'Track ${track.label} added: ,id: ${track.id}, kind: ${track.kind}');
    });
  }

  void addReceiveTransceivers(
      RTCPeerConnection? peer, Map<String, dynamic> options) {
    RTCRtpTransceiverInit initOptions =
        RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly);
    if (options['disableVideo']) {
      peer?.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: initOptions);
    }
    if (options['disableAudio']) {
      peer?.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeAudio, init: initOptions);
    }

    if (options['multiplexedAudioTracks'] != null) {
      for (var i = 0; i < options['multiplexedAudioTracks']; i++) {
        peer?.addTransceiver(
            kind: RTCRtpMediaType.RTCRtpMediaTypeAudio, init: initOptions);
      }
    }
  }

  /// Get peer connection state.
  ///
  /// Returns [String] which represents the [peer] connection state.
  String getConnectionState(RTCPeerConnection peer) {
    Enum? connectionState = peer.connectionState ?? peer.iceConnectionState;
    switch (connectionState) {
      case RTCPeerConnectionState.RTCPeerConnectionStateConnecting:
        return 'connecting';
      case RTCPeerConnectionState.RTCPeerConnectionStateConnected:
        return 'connected';
      default:
        {
          return connectionState.toString();
        }
    }
  }

  Future<RTCPeerConnection> instanceRTCPeerConnection(
      instanceClass, Map<String, dynamic>? config) async {
    RTCPeerConnection instance = await createPeerConnection(<String, dynamic>{
      ...config!,
      ...<String, dynamic>{'sdpSemantics': 'unified-plan'}
    });
    addPeerEvents(instanceClass, instance);
    return instance;
  }
}
