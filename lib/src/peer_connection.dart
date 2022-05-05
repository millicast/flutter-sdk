import 'dart:async';
import 'dart:convert';

import 'package:eventify/eventify.dart';
import 'package:millicast_flutter_sdk/src/peer_connection_stats.dart';
import 'package:millicast_flutter_sdk/src/utils/sdp_parser.dart';
import 'utils/channel.dart';
import 'utils/reemit.dart';

import 'config.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'logger.dart';
import 'package:http/http.dart' as http;

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

class PeerConnection extends EventEmitter {
  RTCSessionDescription? sessionDescription;
  RTCPeerConnection? peer;
  PeerConnectionStats? peerConnectionStats;

  PeerConnection() : super();

  /// Set TURN server location.
  ///
  /// [url] - New TURN location
  static void setTurnServerLocation(String url) {
    turnServerLocation = url;
  }

  /// Get current TURN location.
  ///
  /// By default, https://turn.millicast.com/webrtc/_turn is the current
  /// TURN location.
  /// Returns TURN url ([turnServerLocation]) [String].
  static String getTurnServerLocation() {
    return turnServerLocation;
  }

  /// Instance new RTCPeerConnection.
  ///
  /// [config] - Peer configuration.
  createRTCPeer([Map<String, dynamic>? config]) async {
    _logger.i('Creating new RTCPeerConnection');
    _logger.d('RTC configuration provided by user: $config');
    config = await getRTCConfiguration(config);
    peer = await instanceRTCPeerConnection(this, config);
  }

  /// Get current RTC peer connection.
  ///
  /// Returns [RTCPeerConnection] Object which represents the Peer Connection.
  Future<RTCPeerConnection> getRTCPeer() async {
    _logger.i('Getting RTC Peer');
    if (peer != null) {
      String connectionState = getConnectionState(peer!);
      RTCSessionDescription? currentLocalDescription =
          await peer!.getLocalDescription();
      RTCSessionDescription? currentRemoteDescription =
          await peer!.getRemoteDescription();
      _logger.d(
          'getRTCPeer return: {$connectionState, $currentLocalDescription, $currentRemoteDescription}');
    }
    return peer!;
  }

  /// Close RTC peer connection.
  ///
  closeRTCPeer() async {
    _logger.i('Closing RTCPeerConnection');
    await peer?.close();
    peer = null;
    stopStats();
    emit(webRTCEvents['connectionStateChange'], this, 'closed');
  }

  /// Get default RTC configuration with ICE servers from Milicast signaling
  /// server and merge it with the user configuration provided. User
  /// configuration has priority over defaults.
  ///
  /// [config] - Options to configure the new [RTCPeerConnection].
  /// Returns a [Map] Future object which represents the RTCConfiguration.
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
  /// Returns a [Future] object which represents a [List] of ice servers.
  getRTCIceServers({String? location}) async {
    location = location ?? turnServerLocation;
    _logger.i('Getting RTC ICE servers');
    _logger.d('RTC ICE servers request location: $location');
    List<dynamic> iceServer = [];

    try {
      http.Response data = await http.put(Uri.parse(location));
      _logger.d('RTC ICE servers response: $data');
      if (jsonDecode(data.body)['s'] == 'ok') {
        // call returns old format,
        // this updates URL to URLS in credentials path.
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

  Future<void> setRTCRemoteSDP(String sdp) async {
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

  /// Get the SDP modified depending the options. Optionally set the
  /// SDP information to local peer.
  ///
  /// [Map] options
  /// [bool] options['stereo'] - True to modify SDP for support stereo.
  /// Otherwise False.
  /// [bool] options['dtx'] - True to modify SDP for supporting dtx in opus.
  /// Otherwise False.*
  /// [MediaStream] options['mediaStream'] - MediaStream to offer in a stream.
  /// This object must have
  /// 1 audio track and 1 video track, or at least one of them.
  /// Alternative you can provide both tracks in an array.
  /// VideoCodec options[' codec'] - Selected codec for support simulcast.
  /// [String] options['scalabilityMode'] - Selected scalability mode.
  /// You can get the available capabilities using  method.
  /// **Only available in Google Chrome.**
  /// *[bool] options['absCaptureTime'] - True to modify SDP for
  /// supporting absolute capture time header extension. Otherwise False.
  /// [bool] options['dependencyDescriptor'] - True to modify SDP for supporting
  /// aom dependency descriptor header extension. Otherwise False.
  /// [bool] options['disableAudio'] - True to not support audio.
  /// [bool] options['disableVideo'] - True to not support video.
  /// [bool] options['setSDPToPeer'] - True to set the SDP to local peer.
  /// Returns [String] Future object which represents the SDP information
  /// of the created offer.
  Future<String?> getRTCLocalSDP(
      {Map<String, dynamic> options = localSDPOptions}) async {
    _logger.i('Getting RTC Local SDP');
    options = {...localSDPOptions, ...options};

    MediaStream? mediaStream =
        await getValidMediaStream(options['mediaStream']);
    if (mediaStream != null) {
      addMediaStreamToPeer(peer, mediaStream, options);
    } else {
      await addReceiveTransceivers(peer, options);
    }

    _logger.i('Creating peer offer');
    _logger.i('my peer $peer');
    RTCSessionDescription? response = await peer?.createOffer();
    _logger.i('Peer offer created');
    _logger.d('Peer offer response: ${response?.sdp}');
    sessionDescription = response;
    if (response != null) {
      String? sdp = response.sdp;
      if (options.containsKey('disableAudio')) {
        if (!options['disableAudio']) {
          if (options['stereo']) {
            sdp = SdpParser.setStereo(sdp);
          }
          if (options['dtx'] != null) {
            sdp = SdpParser.setDTX(sdp);
          }
          if (mediaStream != null) {
            sdp = SdpParser.setMultiopus(sdp, mediaStream);
          }
        }
      }
      if (options['absCaptureTime'] != null) {
        sdp = SdpParser.setAbsoluteCaptureTime(sdp);
      }
      if (options['dependencyDescriptor'] != null) {
        sdp = SdpParser.setDependencyDescriptor(sdp);
      }
      sessionDescription?.sdp = sdp;
      if (options['setSDPToPeer'] != null) {
        await peer?.setLocalDescription(sessionDescription!);
        _logger.i('Peer local description set');
      }
    }
    return sessionDescription?.sdp;
  }

  /// Add remote receving track.
  ///
  /// [media] - Media kind ('audio' | 'video').
  /// [streams] - Streams the track will belong to.
  /// [Future] that will be resolved when the [RTCRtpTransceiver]
  /// is assigned an mid value.
  addRemoteTrack(media, List<MediaStream> streams) async {
    Completer completer = Completer();
    var transceiverCompleter = RTCRtpTransceiverCompleter(completer);
    try {
      for (var stream in streams) {
        stream.getTracks().forEach((track) async {
          transceiverCompleter.transceiver = await peer!.addTransceiver(
              track: track,
              kind: media,
              init: RTCRtpTransceiverInit(
                  direction: TransceiverDirection.RecvOnly));
          stream.addTrack(transceiverCompleter.transceiver!.receiver.track!);
          transceiverCompleter.completer = completer;
          return completer.future;
        });
      }
    } catch (e) {
      throw Exception(e);
    }
  }

  String updateBandwidthRestriction(String? sdp, num bitrate) {
    _logger.i('Updating bandwidth restriction, bitrate value: $bitrate');
    _logger.d('SDP value: $sdp');
    return SdpParser.setVideoBitrate(sdp, bitrate);
  }

  /// Set SDP information to remote peer with bandwidth restriction.
  ///
  /// [bitrate] - New bitrate value in kbps or 0 unlimited bitrate.
  /// Returns [Future] object which resolves when bitrate was successfully
  /// updated.
  updateBitrate({num bitrate = 0}) async {
    if (peer == null) {
      _logger.e('Cannot update bitrate. No peer found.');
      throw Exception('Cannot update bitrate. No peer found.');
    }

    _logger.i('Updating bitrate to value: ', bitrate);
    sessionDescription = await peer!.createOffer();
    await peer?.setLocalDescription(sessionDescription!);
    String? sdp = updateBandwidthRestriction(
        (await peer!.getRemoteDescription())?.sdp, bitrate);
    await setRTCRemoteSDP(sdp);
    _logger.i(
        'Bitrate restirctions updated:  ${bitrate > 0 ? bitrate : 'unlimited'} kbps');
  }

  String? getRTCPeerStatus() {
    _logger.i('Getting RTC peer status');
    if (peer == null) {
      return null;
    }
    String connectionState = getConnectionState(peer!);
    _logger.i('RTC peer status getted, value: $connectionState');
    return connectionState;
  }

  /// Replace current audio or video track that is being broadcasted.
  ///
  /// [mediaStreamTrack] - New audio or video track to replace the current one.
  void replaceTrack(MediaStreamTrack mediaStreamTrack) async {
    if (peer == null) {
      _logger.e('Could not change track if there is not an active connection.');
      return;
    }

    try {
      RTCRtpSender? currentSender = (await peer!.getSenders()).firstWhere(
          (s) => s.track?.kind == mediaStreamTrack.kind,
          orElse: () => ());
      currentSender.replaceTrack(mediaStreamTrack);
    } catch (e) {
      _logger
          .e('There is no ${mediaStreamTrack.kind} track in active broadcast.');
    }
  }

  /// Gets user's mobile media capabilities compared with
  /// Millicast Media Server support.
  ///
  /// [kind] - Type of media for which you wish to get sender capabilities.
  /// Returns [Map] with all capabilities supported by user's mobile and
  /// Millicast Media Server.
  /// Bug: This ticket is related to the implementation of
  /// jsTrack.getCapabilities(), https://github.com/dart-lang/sdk/issues/44319
  static Future<Map> getCapabilities(String kind) async {
    if (kind == 'video') {
      List<String> codecs = await NativeChannel.supportedCodecs;
      _logger.i('Supported video codecs for this device are $codecs');
      return {'codec': codecs};
    } else {
      // kind is audio
      return {'codec': []};
    }
  }

  /// Get sender tracks
  /// Returns [List] of [MediaStreamTrack] with all tracks in sender peer.
  Future<List<MediaStreamTrack?>> getTracks() async {
    return Future(() async {
      return (await peer?.getSenders())!.map((sender) => sender.track).toList();
    });
  }

  /// Initialize the statistics monitoring of the [RTCPeerConnection].
  /// It will be emitted every second.
  ///
  /// ```dart
  /// import 'package:flutter_webrtc/flutter_webrtc.dart';
  /// import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
  ///
  /// //Initialize and connect your Publisher
  /// var millicastPublish = Publish(streamName, tokenGenerator);
  /// await millicastPublish.connect(options);
  ///
  /// //Initialize get stats
  /// millicastPublish.webRTCPeer.initStats();
  ///
  /// //Capture new stats from event every second
  /// millicastPublish.webRTCPeer.on('stats', (stats) => {
  ///   print('Stats from event: ', stats)
  /// });
  /// ```
  ///
  /// ```dart
  /// import 'package:flutter_webrtc/flutter_webrtc.dart';
  /// import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
  ///
  /// //Initialize and connect your Viewer
  /// var millicastView = View(streamName, tokenGenerator);
  /// await millicastView.connect();
  ///
  /// //Initialize get stats
  /// millicastView.webRTCPeer.initStats();
  ///
  /// //Capture new stats from event every second
  /// millicastView.webRTCPeer.on('stats', (stats) => {
  ///   print('Stats from event: ', stats);
  /// });
  /// ```
  initStats() {
    if (peerConnectionStats != null) {
      _logger.w('Cannot init peer stats: Already initialized');
    } else if (peer != null) {
      peerConnectionStats = PeerConnectionStats(peer!);
      peerConnectionStats?.init();
      reemit(peerConnectionStats!, this, [peerConnectionStatsEvents['stats']]);
    } else {
      _logger.w('Cannot init peer stats: RTCPeerConnection not initialized');
    }
  }

  /// Stops the monitoring of [RTCPeerConnection] statistics.
  ///
  stopStats() {
    peerConnectionStats?.stop();
    peerConnectionStats = null;
  }

  bool isMediaStreamValid(MediaStream mediaStream) {
    return mediaStream.getAudioTracks().length <= 1 &&
        mediaStream.getVideoTracks().length <= 1;
  }

  Future<MediaStream?> getValidMediaStream(MediaStream? mediaStream) async {
    if (mediaStream == null) {
      return null;
    }

    if (isMediaStreamValid(mediaStream)) {
      return mediaStream;
      // ignore: unnecessary_type_check
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
    return null;
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

  /// Emits peer events.
  ///
  /// instanceClass - [PeerConnection] instance.
  /// [RTCPeerConnection] peer - Peer instance.
  ///  PeerConnection#track
  ///  PeerConnection#connectionStateChange
  void addPeerEvents(PeerConnection instanceClass, RTCPeerConnection peer) {
    peer.onTrack = (event) async {
      _logger.i('New track from peer.');
      _logger.d('Track event value: $event');

      // Listen for remote tracks events for resolving pending addRemoteTrack calls.
      // TO DO
      // if (event.transceiver != null) {}
      // ;

      instanceClass.emit(webRTCEvents['track'], this, event.streams[0]);
    };
    if (peer.connectionState != null) {
      peer.onConnectionState = (event) {
        _logger.i('Peer connection state change: ${peer.connectionState}');
        instanceClass.emit(webRTCEvents['connectionStateChange'], this,
            peer.iceConnectionState);
      };
    } else {
      peer.onIceConnectionState = (RTCIceConnectionState state) {
        _logger
            .i('Peer ICE connection state change: ${peer.iceConnectionState}');
        instanceClass.emit(webRTCEvents['connectionStateChange'], this,
            peer.iceConnectionState);
      };
    }

    // No renegotationNeeded
    peer.onRenegotiationNeeded = () async {};
  }

  void addMediaStreamToPeer(RTCPeerConnection? peer, MediaStream? mediaStream,
      Map<String, dynamic> options) {
    _logger.i('Adding mediaStream tracks to RTCPeerConnection');

    mediaStream?.getTracks().forEach((track) {
      RTCRtpTransceiverInit initOptions = RTCRtpTransceiverInit();
      if (track.kind == 'audio') {
        initOptions = RTCRtpTransceiverInit(
            direction: (!options['disableAudio']
                ? TransceiverDirection.SendOnly
                : TransceiverDirection.Inactive),
            streams: [
              mediaStream
            ],
            sendEncodings: [
              RTCRtpEncoding(
                rid: 'f',
                maxBitrate: 900000,
                numTemporalLayers: 3,
              )
            ]);
      }
      if (track.kind == 'video') {
        initOptions = RTCRtpTransceiverInit(
            direction: (!options['disableVideo']
                ? TransceiverDirection.SendOnly
                : TransceiverDirection.Inactive),
            streams: [mediaStream],
            // Choose bitrates for each encoding
            sendEncodings: (options['simulcast'])
                ? [
                    RTCRtpEncoding(
                      rid: '2',
                      numTemporalLayers: 1,
                    ),
                    RTCRtpEncoding(
                      rid: '1',
                      numTemporalLayers: 1,
                      maxBitrate: 300000,
                      scaleResolutionDownBy: 2.0,
                    ),
                    RTCRtpEncoding(
                      rid: '0',
                      numTemporalLayers: 1,
                      maxBitrate: 100000,
                      scaleResolutionDownBy: 4.0,
                    ),
                  ]
                : null);
      }
      peer?.addTransceiver(
          track: track,
          kind: (track.kind == 'audio')
              ? RTCRtpMediaType.RTCRtpMediaTypeAudio
              : RTCRtpMediaType.RTCRtpMediaTypeVideo,
          init: initOptions);
      _logger.i(
          'Track ${track.label} added: ,id: ${track.id}, kind: ${track.kind}');
    });
  }

  Future<void> addReceiveTransceivers(
      RTCPeerConnection? peer, Map<String, dynamic> options) async {
    RTCRtpTransceiverInit initOptions =
        RTCRtpTransceiverInit(direction: TransceiverDirection.RecvOnly);
    if (!options['disableVideo']) {
      peer?.addTransceiver(
          kind: RTCRtpMediaType.RTCRtpMediaTypeVideo, init: initOptions);
    }
    if (!options['disableAudio']) {
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
}

class RTCRtpTransceiverCompleter {
  Completer completer;
  RTCRtpTransceiver? transceiver;
  RTCRtpTransceiverCompleter(this.completer, [this.transceiver]);
}
