import 'package:example/utils/constants.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

Future publishConnect(RTCVideoRenderer localRenderer) async {
  // Setting subscriber options
  DirectorPublisherOptions directorPublisherOptions = DirectorPublisherOptions(
      token: Constants.publishToken, streamName: Constants.streamName);

  /// Define callback for generate new token
  tokenGenerator() => Director.getPublisher(directorPublisherOptions);

  /// Create a new instance
  Publish publish =
      Publish(streamName: Constants.streamName, tokenGenerator: tokenGenerator);

  final Map<String, dynamic> contrains = <String, bool>{
    'audio': true,
    'video': true
  };

  MediaStream stream = await navigator.mediaDevices.getUserMedia(contrains);
  localRenderer.srcObject = stream;

  //Publishing Options
  var broadcastOptions = {'mediaStream': stream};

  /// Start connection to publisher
  try {
    await publish.connect(options: broadcastOptions);
    return publish.webRTCPeer;
  } catch (e) {
    throw Exception(e);
  }
}
