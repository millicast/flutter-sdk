import 'package:example/millicast_publisher_user_media.dart';
import 'package:example/utils/constants.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

Future<MillicastPublishUserMedia> publishConnect(
    RTCVideoRenderer localRenderer) async {
  // Setting subscriber options
  DirectorPublisherOptions directorPublisherOptions = DirectorPublisherOptions(
      token: Constants.publishToken, streamName: Constants.streamName);

  /// Define callback for generate new token`
  tokenGenerator() => Director.getPublisher(directorPublisherOptions);

  /// Create a new instance
  MillicastPublishUserMedia publish = await MillicastPublishUserMedia.build(
      {'streamName': Constants.streamName}, tokenGenerator, true);

  localRenderer.srcObject = publish.mediaManager?.mediaStream;

  /// Start connection to publisher
  try {
    await publish.connect();
    return publish;
  } catch (e) {
    throw Exception(e);
  }
}
