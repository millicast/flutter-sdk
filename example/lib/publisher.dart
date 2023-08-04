import 'package:example/millicast_publisher_user_media.dart';
import 'package:example/utils/constants.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

Future<MillicastPublishUserMedia> buildPublisher(
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
  return publish;
}

Future<MillicastPublishUserMedia> connectPublisher(
    MillicastPublishUserMedia publish, Map mainOptions) async {
  /// Start connection to publisher
  try {
    Map<String, dynamic> options = {
      'events': ['active', 'inactive', 'layers', 'viewercount']
    };

    options['codec'] = 'vp8';

    if (mainOptions.containsKey('sourceId')) {
      options['sourceId'] = mainOptions['sourceId'];
    }
    if (mainOptions.containsKey('stereo')) {
      options['stereo'] = mainOptions['stereo'];
    }
    if (mainOptions.containsKey('dtx')) {
      options['dtx'] = mainOptions['dtx'];
    }
    if (mainOptions.containsKey('absCaptureTime')) {
      options['absCaptureTime'] = mainOptions['absCaptureTime'];
    }
    if (mainOptions.containsKey('dependencyDescriptor')) {
      options['dependencyDescriptor'] = mainOptions['dependencyDescriptor'];
    }
    if (mainOptions.containsKey('simulcast')) {
      options['simulcast'] = mainOptions['simulcast'];
    }
    if (mainOptions.containsKey('codec')) {
      options['codec'] = mainOptions['codec'];
    }
    if (mainOptions.containsKey('bandwidth')) {
      options['bandwidth'] = mainOptions['bandwidth'];
    }

    await publish.connect(options: options);
    return publish;
  } catch (e) {
    throw Exception(e);
  }
}
