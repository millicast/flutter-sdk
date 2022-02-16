// ignore_for_file: lines_longer_than_80_chars

import 'dart:convert';

import 'package:millicast_flutter_sdk/src/config.dart';

import 'utils/event_subscriber.dart';
import 'logger.dart';

var _logger = getLogger('StreamEvents');

const userCountTarget = 'SubscribeViewerCount';
const userCountTargetResponse = 'SubscribeViewerCountResponse';

const Map<String, dynamic> messageType = {'REQUEST': 1, 'RESPONSE': 3};
num invocationId = 0;

const String errorMsg =
    'You need to initialize stream event with StreamEvents.init()';

const String defaultEventsLocation = Config.millicastEventsLocation;
var eventsLocation = defaultEventsLocation;

///
///  [Object] OnUserCountOptions
///  [String] accountId - Millicast Account Id.
///  [String] streamName - Millicast Stream Name.
///  [onUserCountCallback] callback - Callback function executed when a new message is available.
///
///

///
/// Callback invoke when new user count is received.
/// @callback onUserCountCallback
///  [Map] data
///  [String] data['streamId'] - Stream identifier with the following format `accountId/streamName`.
///  [num] data['count']    - Current amount of viewers of the stream.
///  [String] data.error  - Error message.
///
/// StreamEvents
/// Lets you to subscribe to stream events like receive the amount of viewers of a stream.
/// This events are handled via a WebSocket with Millicast server.
///

class StreamEvents {
  EventSubscriber? eventSubscriber;

  ///
  /// Initializes the connection with Millicast Stream Event.
  /// Returns [Future<StreamEvents>] Future object which represents the StreamEvents instance
  /// once the connection with the Millicast stream events is done.
  /// @example const streamEvents = await StreamEvents.init()
  ///
  static init() async {
    StreamEvents instance = StreamEvents();
    instance.eventSubscriber = EventSubscriber(getEventsLocation());
    await instance.eventSubscriber?.initializeHandshake();

    return instance;
  }

  /// Set Websocket Stream Events location.
  ///
  ///  [String] url - New Stream Events location
  ///

  static setEventsLocation(String url) {
    eventsLocation = url;
  }

  ///
  /// Get current Websocket Stream Events location.
  ///
  /// By default, wss://streamevents.millicast.com/ws is the location.
  /// Returns [String] Stream Events location
  ///
  static String getEventsLocation() {
    return eventsLocation;
  }

  void onUserCount(Map<String, dynamic> options,
      {String? streamName, Function? callback}) {
    if (eventSubscriber == null) {
      _logger.e(errorMsg);
      throw Error();
    }
    var optionsParsed = getOnUserCountOptions(options);
    _logger.i(
        'Starting user count. AccountId: ${optionsParsed['accountId']}, streamName: ${optionsParsed['streamName']}');
    String streamId =
        '${optionsParsed['accountId']}/${optionsParsed['streamName']}';
    var requestInvocationId = invocationId++;
    Map<String, dynamic> userCountRequest = {
      'arguments': [
        [streamId]
      ],
      'invocationId': requestInvocationId.toString(),
      'streamIds': [],
      'target': userCountTarget,
      'type': 1
    };
    eventSubscriber?.subscribe(userCountRequest);

    eventSubscriber?.on('message', this, (ev, context) {
      handleStreamCountResponse(streamId, requestInvocationId,
          ev.eventData.toString(), options['callback']);
    });
  }

  ///
  /// Stop listening to stream events connected.
  ///  streamEvents.stop()
  ///
  void stop() {
    eventSubscriber?.close();
  }

  void handleStreamCountResponse(String streamIdConstraint,
      num invocationIdConstraint, String? responseEvent, Function? callback) {
    var response = jsonDecode(responseEvent!) as Map<String, dynamic>;
    if (response['type'] == messageType['REQUEST'] &&
        response['target'] == userCountTargetResponse) {
      for (var item in response['arguments']) {
        if (item['streamId'] == streamIdConstraint) {
          var countChange = item['count'];
          callback!(countChange);
        }
      }
    }
    if (response['type'] == messageType['RESPONSE'] &&
        response['invocationId'] == invocationIdConstraint &&
        response['error']) {
      Map<String, dynamic> countData = {
        'error': response['error'],
        'streamId': streamIdConstraint
      };
      _logger.e('User count error: ${response['error']}');
      callback!(countData);
    }
  }

  getOnUserCountOptions(Map<String, dynamic> options) {
    return options;
  }
}
