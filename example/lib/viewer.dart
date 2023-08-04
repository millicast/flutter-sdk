import 'dart:convert';

import 'package:example/utils/constants.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

Set<String> sourceIds = {};
bool isMultisourceEnabled = false;
bool isSimulcastEnabled = false;
List<String> currentLayers = [''];

/// flag for live button
bool isConnectedSubsc = false;

int? oldLayersSize;
int? currentLayerSize;
// ignore: prefer_typing_uninitialized_variables
var selectedVideoSource;
// ignore: prefer_typing_uninitialized_variables
var selectedAudioSource;
var _logger = getLogger('ViewerDemo');

Future buildSubscriber(RTCVideoRenderer localRenderer) async {
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

  view.on(webRTCEvents['track'], view, (ev, context) {
    RTCTrackEvent track = ev.eventData as RTCTrackEvent;

    if (track.streams.isNotEmpty) {
      localRenderer.srcObject = track.streams[0];
    }
  });

  // Based on broadcast events control different(multisource,simulcast) flows with flags and events in the ui
  view.on(SignalingEvents.broadcastEvent, view, (event, context) {
    String eventData = json.encode(event.eventData);
    Map<String, dynamic> eventDataMap = jsonDecode(eventData);

    switch (eventDataMap['name']) {
      // Case simulcast is enabled
      case 'layers':
        isSimulcastEnabled = true;
        currentLayerSize = eventDataMap['data']['medias']['0']['active'].length;

        if (currentLayerSize != oldLayersSize) {
          view.emit('layerChange', view);
        }
        if (currentLayerSize == 3) {
          currentLayers = ['Low', 'Medium', 'High', 'Auto'];
        } else if (currentLayerSize == 2) {
          currentLayers = ['Low', 'High', 'Auto'];
        } else {
          isSimulcastEnabled = false;
        }
        oldLayersSize = currentLayerSize;

        break;

      // Case you start publishing
      case 'active':
        isConnectedSubsc = true;
        // Case no multisource, sourceId will be Main
        if (eventDataMap['data']['sourceId'] == null) {
          isMultisourceEnabled = false;
          sourceIds.add('Main');
          view.emit('multisource', view, false);
        }

        // Case multisource is enabled sourceId!= null
        else {
          sourceIds.add(eventDataMap['data']['sourceId']);
          view.emit('multisource', view, true);
          isMultisourceEnabled = true;
        }
        break;

      // Case you stop publishing
      case 'inactive':
        if (eventDataMap['data']['sourceId'] != null) {
          // If the video you are subscribed to is stopped
          if (selectedVideoSource == eventDataMap['data']['sourceId']) {
            // Clean selected value from dropdown
            selectedVideoSource = null;
          }

          // If the audio you are subscribed to is stopped
          if (selectedAudioSource == eventDataMap['data']['sourceId']) {
            // Clean selected value from dropdown
            selectedAudioSource = null;
          }

          // Remove source from dropdownList
          if (eventDataMap['data']['sourceId'] != null) {
            sourceIds.remove(eventDataMap['data']['sourceId']);
          } else {
            sourceIds.remove('Main');
          }
        } else {
          isConnectedSubsc = false;
        }

        // No multisource
        if (sourceIds.isEmpty) {
          isMultisourceEnabled = false;
          view.emit('multisource', view, false);
        } else {
          view.emit('multisource', view, true);
        }

        isSimulcastEnabled = false;
        break;

      default:
    }
  });
  return view;
}

Future viewConnect(View view) async {
  /// Start connection to publisher
  try {
    await view.connect(options: {
      'events': ['active', 'inactive', 'layers', 'viewercount'],
    });

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
    _logger.e(e);
  }
}
