import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/utils/base_web_rtc.dart';

const Map<String, dynamic> connectOptionsView = {'': ''};
const Object loggerView = {};

class View extends BaseWebRTC {
  View(
      {required String streamName,
      required Function tokenGenerator,
      RTCVideoRenderer? mediaElement,
      bool autoReconnect = true})
      : super(
            streamName: streamName,
            tokenGenerator: tokenGenerator,
            autoReconnect: autoReconnect,
            loggerInstance: loggerView);

  void connect(
      {Map<String, dynamic> connectOptions = connectOptionsView}) async {}
  void select(Map? layer) async {}

  Future<RTCRtpTransceiver> addRemoteTrack(
      String media, List<MediaStream> streams) async {
    // ignore: null_argument_to_non_null_type
    return Future<RTCRtpTransceiver>.value();
  }

  void project(String sourceId, List<Object> mapping) async {}
  void unproject(List<String> mediaIds) async {}
}
