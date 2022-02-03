import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../logger.dart';

// ignore: unused_element
var _logger = getLogger('SdpParser');

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
  static String? setSimulcast(RTCSessionDescription sdp, String codec) {
    return sdp.sdp;
  }

  static String? setStereo(RTCSessionDescription sdp) {
    return sdp.sdp;
  }

  static String? setDTX(RTCSessionDescription sdp) {
    return sdp.sdp;
  }

  static String? setAbsoluteCaptureTime(RTCSessionDescription sdp) {
    return sdp.sdp;
  }

  static String? setDependencyDescriptor(RTCSessionDescription sdp) {
    return sdp.sdp;
  }

  static String? setVideoBitrate(RTCSessionDescription sdp, num bitrate) {
    return sdp.sdp;
  }

  static String? removeSdpLine(
      RTCSessionDescription sdp, RTCSessionDescription sdpLine) {
    return sdp.sdp;
  }

  static String? adaptCodecName(
      RTCSessionDescription sdp, String codec, String newCodecName) {
    return sdp.sdp;
  }

  static String? setMultiopus(
      RTCSessionDescription sdp, MediaStream mediaStream) {
    return sdp.sdp;
  }

  static List<num> getAvailablePayloadTypeRange(RTCSessionDescription sdp) {
    return [];
  }

  static List<num> getAvailableHeaderExtensionIdRange(
      RTCSessionDescription sdp) {
    return [];
  }

  static String? renegotiate(String localDescription, String remoteDescriptio) {
    return '';
  }

  bool hasAudioMultichannel(MediaStream mediaStream) {
    return false;
  }
}
