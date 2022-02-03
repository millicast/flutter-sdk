import 'dart:async';
import 'dart:convert';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:example/utils/constants.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

var _logger = getLogger('Signaling');

Future<RTCPeerConnection> connect(
    String type, RTCVideoRenderer _localRenderer) async {
  MillicastDirectorResponse token = await getToken(type);
  RTCPeerConnection pc = await createPeerConnection(<String, dynamic>{
    ...Constants.rtcPeerConf,
    ...<String, dynamic>{'sdpSemantics': 'unified-plan'}
  }, Constants.offerSdpConstraints);
  String url = token.urls[0];
  String jwt = token.jwt;
  var futures = <Future>[];

  var signaling =
      Signaling({'streamName': Constants.streamName, 'url': '$url?token=$jwt'});

  Future signalingPromise = signaling.connect();
  if (type == 'publish') {
    EventSubscriber userEvent =
        EventSubscriber('wss://streamevents.millicast.com/ws');
    await userEvent.initializeHandshake();
    userEvent.subscribe(Constants.topicRequest);

    final Map<String, dynamic> contrains = <String, bool>{
      'audio': true,
      'video': true
    };
    MediaStream stream = await navigator.mediaDevices.getUserMedia(contrains);
    stream.getTracks().forEach((track) {
      pc.addTrack(track, stream);
      _localRenderer.srcObject = stream;
    });
  } else {
    pc = await createAndSetStream(pc);
  }

  var localSDPPromise = getLocalSDP(pc);
  futures.add(localSDPPromise);
  futures.add(signalingPromise);
  var resolvedPromises = await Future.wait(futures);
  RTCSessionDescription localSdp = resolvedPromises[0];
  Future promise;
  if (type == 'publish') {
    promise = signaling.publish(localSdp);
  } else {
    promise = signaling.subscribe(localSdp);
  }
  var setLocalDescriptionPromise = setLocalSdp(localSdp, pc);
  futures.add(promise);
  futures.add(setLocalDescriptionPromise);
  await Future.wait(futures);
  signaling.on('remoteSdp', pc, (event, context) {
    setRemoteSdp(event.eventData.toString(), pc);
  });
  // listenMessageFromChannel(pc, signaling.webSocket);
  return pc;
}

Future<RTCSessionDescription> getLocalSDP(RTCPeerConnection pc) async {
  RTCSessionDescription localSDP = await pc.createOffer(
      <String, bool>{'offerToReceiveAudio': true, 'offerToReceiveVideo': true});
  return localSDP;
}

setRemoteSdp(var remoteSdp, RTCPeerConnection pc) async {
  try {
    var sdp = RTCSessionDescription(remoteSdp, 'answer');
    await pc.setRemoteDescription(sdp);
    _logger.i('setRemoteDescription Success! ');
  } catch (e) {
    _logger.i('setRemoteDescription failed: $e');
  }
}

setLocalSdp(RTCSessionDescription localSdp, RTCPeerConnection pc) async {
  try {
    await pc.setLocalDescription(localSdp);
  } catch (e) {
    throw Exception('creaateOffer Failed: $e');
  }
}

void listenMessageFromChannel(RTCPeerConnection pc, WebSocketChannel? channel) {
  channel?.stream.listen((dynamic message) {
    final Map<String, dynamic> decodedMessage =
        jsonDecode(message as String) as Map<String, dynamic>;
    switch (decodedMessage['type']) {
      //Handle counter response coming from the Media Server.
      case 'response':
        dynamic sdp = decodedMessage['data']['sdp'];
        var answer = RTCSessionDescription(
            '$sdp' 'a=x-google-flag:conference\r\n', 'answer');
        pc
            .setRemoteDescription(answer)
            .then((d) => {_logger.i('setRemoteDescription Success! ')})
            .catchError(
                (dynamic e) => {_logger.i('setRemoteDescription failed: $e')});
        break;
      //Handle counter response coming from the Media Server.
      case 'event':
        break;
    }
  });
}

Future<RTCPeerConnection> createAndSetStream(
  RTCPeerConnection pc,
) async {
  //Create dummy stream
  MediaStream stream = await createLocalMediaStream('mystream');

  RTCRtpMediaType audio = RTCRtpMediaType.RTCRtpMediaTypeAudio;

  RTCRtpTransceiverInit initAudio = RTCRtpTransceiverInit(
      direction: TransceiverDirection.RecvOnly, streams: [stream]);

  RTCRtpMediaType video = RTCRtpMediaType.RTCRtpMediaTypeVideo;

  RTCRtpTransceiverInit initVideo = RTCRtpTransceiverInit(
      direction: TransceiverDirection.RecvOnly, streams: [stream]);

  pc.addTransceiver(kind: audio, init: initAudio);
  pc.addTransceiver(kind: video, init: initVideo);

  return pc;
}

Map<String, dynamic> generatePayload(RTCSessionDescription desc, String type) {
  final Map<String, dynamic> payload = <String, dynamic>{
    'type': 'cmd',
    'transId': 23479410,
    'name': (type == 'publish') ? type : 'view',
    'data': {
      'streamId': Constants.streamName, //Millicast viewer streamId
      'sdp': desc.sdp
    }
  };
  return payload;
}

Future<MillicastDirectorResponse> getToken(String type) async {
  switch (type) {
    case 'publish':
      var options = DirectorPublisherOptions(
          streamName: Constants.streamName, token: Constants.publishToken);
      MillicastDirectorResponse token = await Director.getPublisher(options);
      return token;
    case 'subscribe':
      var options = DirectorSubscriberOptions(
          streamName: Constants.streamName,
          streamAccountId: Constants.accountId);
      MillicastDirectorResponse token = await Director.getSubscriber(options);
      return token;
    default:
      return MillicastDirectorResponse(jwt: '', urls: ['']);
  }
}
