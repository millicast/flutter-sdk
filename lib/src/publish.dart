import 'dart:async';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/src/utils/fetch_error.dart';

import 'director.dart';
import 'logger.dart';
import 'peer_connection.dart';
import 'signaling.dart';
import 'utils/base_web_rtc.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'dart:convert';
import 'utils/reemit.dart';

const Map<String, dynamic> connectOptions = {
  'mediaStream': null,
  'bandwidth': 0,
  'disableVideo': false,
  'disableAudio': false,
  'codec': 'h264',
  'simulcast': false,
  'scalabilityMode': null,
  'peerConfig': null
};

var _logger = getLogger('Publish');

/// Manages connection with a secure WebSocket path to signal the Millicast
/// server and establishes a WebRTC connection to broadcast a MediaStream.
///
/// [streamName] - Millicast existing stream name.
/// [tokenGenerator] - Callback function executed when a new token is needed.
/// [logger] - Logger instance from the extended classes.
/// [autoReconnect] - Enable auto reconnect.
class Publish extends BaseWebRTC {
  Function? stopReemitingWebRTCPeerInstanceEvents;

  Function? stopReemitingSignalingInstanceEvents;

  Publish(
      {required String streamName,
      required Function tokenGenerator,
      bool autoReconnect = true})
      : super(
            streamName: streamName,
            tokenGenerator: tokenGenerator,
            autoReconnect: autoReconnect,
            logger: _logger);
  @override
  connect({Map<String, dynamic> options = connectOptions}) async {
    this.options = {...connectOptions, ...options, 'setSDPToPeer': false};
    await initConnection({'migrate': false});
  }

  @override
  replaceConnection() async {
    _logger.i('Migrating current connection');
    options?['mediaStream'] = options?['mediaStream'] ?? webRTCPeer.getTracks();
    await initConnection({'migrate': true});
  }

  @override
  reconnect() {
    options?['mediaStream'] = options?['mediaStream'] ?? webRTCPeer.getTracks();
    super.reconnect();
  }

  initConnection(Map<dynamic, dynamic> data) async {
    _logger.i('Broadcast option values: $options');
    List futures;
    MillicastDirectorResponse publisherData;
    if (options?['mediaStream'] == null) {
      _logger.e('Error while broadcasting. MediaStream required');
      throw Exception('MediaStream required');
    }
    if (isActive() && data['migrate'] == false) {
      throw Exception('Broadcast curretly active');
    }
    try {
      publisherData = await tokenGenerator();
    } on FetchException catch (error) {
      _logger.e('Error generating token.');
      if(error.status == 401) {
        // should not reconnect
        this.stopReconnection = true;
      } else {
        // should reconnect with exponential back off
        reconnect();
      }
      rethrow;
    } catch (error) {
      rethrow;
    }
    if (publisherData.urls.isEmpty && publisherData.jwt.isEmpty) {
      _logger.e('Error while broadcasting. Publisher data required');
      throw Exception('Publisher data is required');
    }
    bool recordingAvailable = Jwt.parseJwt(publisherData.jwt)[
        utf8.decode(base64.decode('bWlsbGljYXN0'))]['record'];
    if (options?['record'] != null && !recordingAvailable) {
      _logger.e(
          '''Error while broadcasting. Record option detected but recording is not available''');
      throw Exception('Record option detected but recording is not available');
    }
    var signalingInstance = Signaling({
      'streamName': streamName,
      'url': '${publisherData.urls[0]}?token=${publisherData.jwt}'
    });

    var webRTCPeerInstance = data['migrate'] ? PeerConnection() : webRTCPeer;

    await webRTCPeerInstance.createRTCPeer(options?['peerConfig']);

    // Stop emiting events from the previous instances
    if (stopReemitingWebRTCPeerInstanceEvents != null) {
      stopReemitingWebRTCPeerInstanceEvents!();
    }
    if (stopReemitingSignalingInstanceEvents != null) {
      stopReemitingSignalingInstanceEvents!();
    }

    stopReemitingWebRTCPeerInstanceEvents = reemit(
        webRTCPeerInstance, this, [webRTCEvents['connectionStateChange']]);
    stopReemitingSignalingInstanceEvents =
        reemit(signalingInstance, this, [SignalingEvents.broadcastEvent]);

    Future<String?> getLocalSDPFuture =
        webRTCPeerInstance.getRTCLocalSDP(options: options!);
    Future signalingConnectFuture = signalingInstance.connect();
    Iterable<Future<dynamic>> iterFuture = [
      getLocalSDPFuture,
      signalingConnectFuture
    ];
    futures = await Future.wait(iterFuture);
    String? localSdp = futures[0];

    var publishFuture = signalingInstance.publish(localSdp, options: options);
    var setLocalDescriptionFuture = webRTCPeerInstance.peer!
        .setLocalDescription(webRTCPeerInstance.sessionDescription!);
    iterFuture = [publishFuture, setLocalDescriptionFuture];
    futures = await Future.wait(iterFuture);
    String remoteSdp = futures[0];
    await setLocalDescriptionFuture;

    if (!options?['disableVideo'] && (options?['bandwidth'] > 0)) {
      remoteSdp = webRTCPeerInstance.updateBandwidthRestriction(
          remoteSdp, options?['bandwidth']);
    }

    await webRTCPeerInstance.setRTCRemoteSDP(remoteSdp);
    _logger.i('Broadcasting to streamName: $streamName');

    Signaling? oldSignlaling = signaling;
    PeerConnection? oldWebRTCPeer = webRTCPeer;
    signaling = signalingInstance;
    webRTCPeer = webRTCPeerInstance;
    setReconnect();

    if (data['migrate']) {
      webRTCPeer.on(webRTCEvents['connectionStateChange'], webRTCPeer,
          (ev, context) async {
        if (ev.eventData ==
            RTCIceConnectionState.RTCIceConnectionStateConnected) {
          Timer(const Duration(milliseconds: 1000), () {
            oldSignlaling?.close();
            oldWebRTCPeer?.closeRTCPeer();
            oldSignlaling = null;
            oldWebRTCPeer = null;
            _logger.i('Current connection migrated');
          });
        } else if ([
          RTCIceConnectionState.RTCIceConnectionStateClosed,
          RTCIceConnectionState.RTCIceConnectionStateFailed,
          RTCIceConnectionState.RTCIceConnectionStateDisconnected
        ].contains(ev.eventData)) {
          oldSignlaling?.close();
          oldWebRTCPeer?.closeRTCPeer();
          oldSignlaling = null;
          oldWebRTCPeer = null;
        }
      });
    }
  }
}
