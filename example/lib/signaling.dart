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

  PeerConnection peerConnection = PeerConnection();
  peerConnection.getRTCPeerStatus();
  await peerConnection.createRTCPeer();

  String url = token.urls[0];
  String jwt = token.jwt;
  var futures = <Future>[];
  Future<String?> localSDPPromise;

  var signaling =
      Signaling({'streamName': Constants.streamName, 'url': '$url?token=$jwt'});

  Future signalingPromise = signaling.connect();
  if (type == 'publish') {
    EventSubscriber userEvent =
        EventSubscriber('wss://streamevents.millicast.com/ws');
    await userEvent.initializeHandshake();
    userEvent.subscribe(Constants.topicRequest);

    final Map<String, dynamic> constraints = <String, bool>{
      'audio': true,
      'video': true
    };
    
    MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);
    stream.getTracks().forEach((track) {
      peerConnection.peer?.addTrack(track, stream);
      _localRenderer.srcObject = stream;
    });

    localSDPPromise =
        peerConnection.getRTCLocalSDP(options: {'mediaStream': stream});
  } else {
    peerConnection.peer = await createAndSetStream(peerConnection.peer!);
    localSDPPromise = peerConnection.getRTCLocalSDP(options: {'stereo': true});
  }

  futures.add(localSDPPromise);
  futures.add(signalingPromise);
  var resolvedPromises = await Future.wait(futures);
  String localSdp = resolvedPromises[0];
  Future promise;
  if (type == 'publish') {
    promise = signaling.publish(localSdp);
  } else {
    promise = signaling.subscribe(localSdp);
  }
  var setLocalDescriptionPromise = peerConnection.peer
      ?.setLocalDescription(peerConnection.sessionDescription!);
  futures.add(promise);
  futures.add(setLocalDescriptionPromise!);
  await Future.wait(futures);
  signaling.on('remoteSdp', peerConnection.peer!, (event, context) {
    peerConnection.setRTCRemoteSDP(event.eventData.toString());
    _logger.i('setRemoteDescription Success! ');
  });
  return peerConnection.peer!;
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
