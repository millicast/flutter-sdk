import 'dart:convert';

import 'package:example/utils/constants.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

List<String> sourceIds = [];
bool isMultisourceEnabled = false;
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

  view.on(SignalingEvents.broadcastEvent, view, (event, context) {
    String eventData = json.encode(event.eventData);
    Map<String, dynamic> eventDataMap = jsonDecode(eventData);

    if (eventDataMap['data']['sourceId'] == null &&
        eventDataMap['name'] == 'active') {
      isMultisourceEnabled = false;
      view.emit('simulcast', view, true);
    } else if (eventDataMap['data']['sourceId'] != null) {
      if (!sourceIds.contains(eventDataMap['data']['sourceId'])) {
        sourceIds.add(eventDataMap['data']['sourceId']);
      }
      view.emit('simulcast', view, false);
      isMultisourceEnabled = true;
    }
  });

  /// Start connection to publisher
  try {
    await view.connect();

    view.webRTCPeer.initStats();

    view.webRTCPeer.on('stats', view, (stats, context) {
      if (stats.eventData != null) {
        for (var report in stats.eventData as List<StatsReport>) {
          if (report.type != 'codec') {
            _logger.d('${report.id}, ${report.type}, ${report.timestamp}');
          }
        }
      }
    });
    return view;
  } catch (e) {
    rethrow;
  }
}
