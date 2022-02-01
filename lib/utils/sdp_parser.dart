import 'package:flutter_webrtc/flutter_webrtc.dart';

const Map<String, dynamic> logger = {};

const num firstPayloadTypeLowerRange = 35;
const num lastPayloadTypeLowerRange = 65;

const num firstPayloadTypeUpperRange = 96;
const num lastPayloadTypeUpperRange = 127;

late List<num> payloadTypeLowerRange;
late List<num> payloadTypeUppperRange;

const num firstHeaderExtensionIdLowerRange = 1;
const num lastHeaderExtensionIdLowerRange = 14;

const num firstHeaderExtensionIdUpperRange = 16;
const num lastHeaderExtensionIdUpperRange = 255;

late List<num> headerExtensionIdLowerRange;
late List<num> headerExtensionIdUppperRange;

class SdpParser {
  static String setSimulcast(String sdp, String codec) {
    return '';
  }

  static String setStereo(String sdp) {
    return ' ';
  }

  static String setDTX(String sdp) {
    return ' ';
  }

  static String setAbsoluteCaptureTime(String sdp) {
    return ' ';
  }

  static String setDependencyDescriptor(String sdp) {
    return ' ';
  }

  static String setVideoBitrate(String sdp, num bitrate) {
    return ' ';
  }

  static String removeSdpLine(String sdp, String sdpLine) {
    return ' ';
  }

  static String adaptCodecName(String sdp, String codec, String newCodecName) {
    return ' ';
  }

  static String setMultiopus(String sdp, MediaStream mediaStream) {
    return ' ';
  }

  static List<num> getAvailablePayloadTypeRange(String sdp) {
    return [];
  }

  static List<num> getAvailableHeaderExtensionIdRange(String sdp) {
    return [];
  }

  static String renegotiate(String localDescription, String remoteDescriptio) {
    return '';
  }

  bool hasAudioMultichannel(MediaStream mediaStream) {
    return false;
  }
}
