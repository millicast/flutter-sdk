import 'package:millicast_flutter_sdk/src/director.dart';

import 'logger.dart';
import 'utils/base_web_rtc.dart';
import 'package:jwt_decode/jwt_decode.dart';
import 'dart:convert';
import 'signaling.dart';
import 'peer_connection.dart';
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
// ignore: lines_longer_than_80_chars
///
/// [streamName] - Millicast existing stream name.
//  ignore: lines_longer_than_80_chars
/// [tokenGenerator] - Callback function executed when a new token is needed.
/// [logger] - Logger instance from the extended classes.
/// [autoReconnect] - Enable auto reconnect.
///
class Publish extends BaseWebRTC {
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
    String remoteSdp = '';
    List futures;
    MillicastDirectorResponse publisherData;
    logger.d('Broadcast option values: $options');
    options = {...connectOptions, ...options, 'setSDPToPeer': false};
    if (options['mediaStream'] == null) {
      logger.e('Error while broadcasting. MediaStream required');
      throw Exception('MediaStream required');
    }
    if (isActive()) {
      throw Exception('Broadcast curretly active');
    }
    try {
      publisherData = await tokenGenerator();
    } catch (error) {
      logger.e('Error generating token.');
      rethrow;
    }
    // ignore: unnecessary_null_comparison
    if (publisherData == null) {
      logger.e('Error while broadcasting. Publisher data required');
      throw Exception('Publisher data is required');
    }
    bool recordingAvailable = Jwt.parseJwt(publisherData.jwt)[
        utf8.decode(base64.decode('bWlsbGljYXN0'))]['record'];
    _logger.i('${options['record']}');
    if (options['record'] != null && !recordingAvailable) {
      logger.e(
          // ignore: lines_longer_than_80_chars
          'Error while broadcasting. Record option detected but recording is not available');
      throw Exception('Record option detected but recording is not available');
    }
    var signaling = Signaling({
      'streamName': streamName,
      'url': '${publisherData.urls[0]}?token=${publisherData.jwt}'
    });

    await webRTCPeer.createRTCPeer(options['peerConfig']);

    reemit(webRTCPeer, this, [webRTCEvents['connectionStateChange']]);
    Future<String?> getLocalSDPFuture =
        webRTCPeer.getRTCLocalSDP(options: options);
    Future signalingConnectFuture = signaling.connect();
    Iterable<Future<dynamic>> iterFuture = [
      getLocalSDPFuture,
      signalingConnectFuture
    ];
    futures = await Future.wait(iterFuture);
    String? localSdp = futures[0];
    var publishFuture = signaling.publish(localSdp); //, options: options);
    var setLocalDescriptionFuture =
        webRTCPeer.peer!.setLocalDescription(webRTCPeer.sessionDescription!);
    iterFuture = [publishFuture, setLocalDescriptionFuture];
    futures = await Future.wait(iterFuture);
    remoteSdp = futures[0];
    await setLocalDescriptionFuture;
    if (!options['disableVideo'] && (options['bandwidth'] > 0)) {
      remoteSdp = webRTCPeer.updateBandwidthRestriction(
          remoteSdp, options['bandwidth']);
    }
    await webRTCPeer.setRTCRemoteSDP(remoteSdp);
    _logger.i('setRemoteDescription Success! ');
    setReconnect();
    logger.i('Broadcasting to streamName: $streamName');
  }

  @override
  reconnect() {
    options?['mediaStream'] = options?['mediaStream'];
    super.reconnect();
  }
}
