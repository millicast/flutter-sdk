import 'package:flutter_webrtc/flutter_webrtc.dart';
import '../logger.dart';
import 'package:sdp_transform/sdp_transform.dart';

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
  static String? setSimulcast(String? sdp, String codec) {
    return sdp;
  }

  static String? setStereo(String? sdp) {
    return sdp;
  }

  static String? setDTX(String? sdp) {
    return sdp;
  }

  static String? setAbsoluteCaptureTime(String? sdp) {
    return sdp;
  }

  static String? setDependencyDescriptor(String? sdp) {
    return sdp;
  }

  /// Parse SDP for desired bitrate.
  ///
  /// [sdp] - Current SDP.
  /// [bitrate] - Bitrate value in kbps or 0 for unlimited bitrate.
  /// Returns SDP parsed with desired bitrate.
  ///
  /// ```dart
  /// SdpParser.setVideoBitrate(sdp, 1000);
  /// ```
  static String setVideoBitrate(String? sdp, num bitrate) {
    int video = 0;
    if (sdp != null) {
      if (bitrate < 1) {
        _logger.i('Remove bitrate restrictions');
        sdp = sdp
            .replaceAll(RegExp(r'b=AS:.*\r\n'), 'replace')
            .replaceAll(RegExp(r'b=TIAS:.*\r\n'), '');
      } else {
        _logger.i('Setting video bitrate');
        Map<String, dynamic> parsedSdp = parse(sdp);
        if (parsedSdp['media'][0]['type'] == 'video') {
          video = 0;
        } else if (parsedSdp['media'][1]['type'] == 'video') {
          video = 1;
        } else {
          return sdp;
        }
        parsedSdp['media'][video]['rtp'][0]['rate'] = bitrate;
        parsedSdp['media'][video]['rtp'][1]['rate'] = bitrate;
        sdp = write(parsedSdp, null);
        return sdp;
      }
    }
    return '';
  }

  static String? removeSdpLine(String? sdp, String sdpLine) {
    return sdp;
  }

  static String? adaptCodecName(
      String? sdp, String codec, String newCodecName) {
    return sdp;
  }

  static String? setMultiopus(String? sdp, MediaStream mediaStream) {
    return sdp;
  }

  static List<num> getAvailablePayloadTypeRange(String? sdp) {
    return [];
  }

  static List<num> getAvailableHeaderExtensionIdRange(String? sdp) {
    return [];
  }

  static String? renegotiate(
      String? localDescription, String? remoteDescriptio) {
    return localDescription;
  }

  bool hasAudioMultichannel(MediaStream mediaStream) {
    return false;
  }
}
