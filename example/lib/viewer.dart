import 'package:example/utils/constants.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

var _logger = getLogger('ViewerDemo');

Future viewConnect(RTCVideoRenderer localRenderer) async {
  // Setting subscriber options
  DirectorSubscriberOptions directorSubscriberOptions =
      DirectorSubscriberOptions(
          streamAccountId: Constants.accountId,
          streamName: Constants.streamName);

  /// Define callback for generate new token
  tokenGenerator() => Director.getSubscriber(directorSubscriberOptions);

  /// Create a new instance
  View view = View(
      streamName: Constants.streamName,
      tokenGenerator: tokenGenerator,
      mediaElement: localRenderer);

  /// Start connection to publisher
  try {
    await view.connect();
    view.webRTCPeer.initStats();

    view.webRTCPeer.on('stats', view, (stats, context) {
      if (stats.eventData != null) {
        for (var report in stats.eventData as List<StatsReport>) {
          if (report.type != 'codec') {
            _logger.d(
                '${report.id}, ${report.type}, ${report.timestamp}, ${report.values['candidateType']}, ${report.values['availableOutgoingBitrate']}, ${report.values['totalRoundTripTime']}');
          }
        }
      }
    });
    return view.webRTCPeer;
  } catch (e) {
    rethrow;
  }
}
