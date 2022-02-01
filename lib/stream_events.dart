import 'package:millicast_flutter_sdk/utils/event_subscriber.dart';

const user_count_target = 'SubscribeViewerCount';
const user_count_target_response = 'SubscribeViewerCountResponse';

const Map<String, dynamic> messageType = {};
num invocationId = 0;

const String defaultEventsLocation = '';
const String errorMsg =
    'You need to initialize stream event with StreamEvents.init()';

class StreamEvents {
  EventSubscriber? eventSubscriber;

  static init() async {}

  static setEventsLocation(String url) {}
  static String getEventsLocation() {
    return '';
  }

  void onUserCount(String options, String? streamName, Object? callback) {}

  void stop() {}

  void handleStreamCountResponse(String streamIdConstraint,
      String invocationIdConstraint, Object response, Object callback) {}

  getOnUserCountOptions(
      Object options, String legacyStreamName, Object legacyCallback) {}
}
