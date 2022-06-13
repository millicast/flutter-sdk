import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../logger.dart';
import 'package:sdp_transform/sdp_transform.dart';

var _logger = getLogger('SdpParser');

const Map<String, dynamic> logger = {};

const num firstPayloadTypeLowerRange = 35;
const num lastPayloadTypeLowerRange = 65;

const num firstPayloadTypeUpperRange = 96;
const num lastPayloadTypeUpperRange = 127;

List<num> payloadTypeLowerRange = [
  for (var i = firstPayloadTypeLowerRange;
      i <= lastPayloadTypeLowerRange;
      i += 1)
    i
];
List<num> payloadTypeUppperRange = [
  for (var i = firstPayloadTypeUpperRange;
      i <= lastPayloadTypeUpperRange;
      i += 1)
    i
];

const num firstHeaderExtensionIdLowerRange = 1;
const num lastHeaderExtensionIdLowerRange = 14;

const num firstHeaderExtensionIdUpperRange = 16;
const num lastHeaderExtensionIdUpperRange = 255;

List<num> headerExtensionIdLowerRange = [
  for (var i = firstHeaderExtensionIdLowerRange;
      i <= lastHeaderExtensionIdLowerRange;
      i += 1)
    i
];
List<num> headerExtensionIdUppperRange = [
  for (var i = firstHeaderExtensionIdUpperRange;
      i <= lastHeaderExtensionIdUpperRange;
      i += 1)
    i
];

class SdpParser {
  /// Parse SDP for support simulcast.
  ///
  /// [sdp] - Current SDP.
  /// [codec] - Codec.
  /// Returns SDP [String] parsed with simulcast support.
  static String? setSimulcast(String? sdp, String codec) {
    _logger.i('Setting simulcast. Codec: $codec');
    if (codec != 'h264' && codec != 'vp8') {
      _logger.w('Simulcast is only available in h264 and vp8 codecs');
      return sdp;
    }

    try {
      if (sdp == null) {
        return sdp;
      }
      var reg1 =
          RegExp(r'm=video.*?a=ssrc:(\d*) cname:(.+?)\r\n', dotAll: true);
      var reg2 =
          RegExp(r'm=video.*?a=ssrc:(\d*) mslabel:(.+?)\r\n', dotAll: true);
      var reg3 = RegExp(r'm=video.*?a=ssrc:(\d*) msid:(.+?)\r\n', dotAll: true);
      var reg4 =
          RegExp(r'm=video.*?a=ssrc:(\d*) label:(.+?)\r\n', dotAll: true);
      // Get ssrc and cname
      var ssrc = (reg1.allMatches(sdp).map((e) => e[1])).toList()[0];
      // Get other params
      String? cname = (reg1.allMatches(sdp).map((e) => e[2])).toList()[0];
      String? mslabel = (reg2.allMatches(sdp).map((e) => e[2])).toList()[0];
      String? msid = (reg3.allMatches(sdp).map((e) => e[2])).toList()[0];
      String? label = (reg4.allMatches(sdp).map((e) => e[2])).toList()[0];
      // Add simulcasts ssrcs
      var num = 2;
      var ssrcs = [ssrc];
      if (cname != null && mslabel != null && msid != null && label != null) {
        for (var i = 0; i < num; ++i) {
          // Create new ssrcs
          var ssrc = 100 + i * 2;
          var rtx = ssrc + 1;
          // Add to ssrc list
          ssrcs.add(ssrc.toString());
          // Add sdp stuff
          if (sdp == null) {
            return sdp;
          }
          sdp += 'a=ssrc-group:FID ${ssrc.toString()} ${rtx.toString()}\r\n'
              'a=ssrc:${ssrc.toString()} cname:$cname\r\n'
              'a=ssrc:${ssrc.toString()} msid:$msid\r\n'
              'a=ssrc:${ssrc.toString()} mslabel:$mslabel\r\n'
              'a=ssrc:${ssrc.toString()} label:$label\r\n'
              'a=ssrc:${rtx.toString()} cname:$cname\r\n'
              'a=ssrc:${rtx.toString()} msid:$msid\r\n'
              'a=ssrc:${rtx.toString()} mslabel:$mslabel\r\n'
              'a=ssrc:${rtx.toString()} label:$label\r\n';
        }
        // Conference flag
        sdp = sdp! + 'a=x-google-flag:conference\r\n';
        // Add SIM group
        sdp += 'a=ssrc-group:SIM ' + ssrcs.join(' ') + '\r\n';
        _logger.i('Simulcast setted');
        _logger.d('Simulcast SDP: $sdp');
        return sdp;
      }
    } catch (e) {
      _logger.e('Error setting SDP for simulcast: $e');
      throw Exception(e);
    }
    return null;
  }

  /// Parse SDP for support stereo.
  ///
  /// [sdp] - Current SDP.
  /// Returns [String] SDP parsed with stereo support.
  static String? setStereo(String? sdp) {
    _logger.i('Replacing SDP response for support stereo');
    sdp = sdp!.replaceAll(
        RegExp(r'useinbandfec=1', multiLine: true), 'useinbandfec=1;stereo=1');
    _logger.i('Replaced SDP response for support stereo');
    _logger.d('New SDP value: ', sdp);
    return sdp;
  }

  /// Parse SDP for support dtx.
  ///
  /// [sdp] - Current SDP.
  /// Returns [String] SDP parsed with dtx support.
  static String? setDTX(String? sdp) {
    _logger.i('Replacing SDP response for support dtx');
    sdp = sdp?.replaceAll(RegExp(r'useinbandfec=1'), 'useinbandfec=1;usedtx=1');
    _logger.i('Replaced SDP response for support dtx');
    _logger.d('New SDP value: $sdp');
    return sdp;
  }

  /// Mangle SDP for adding absolute capture time header extension.
  ///
  /// [sdp] - Current SDP.
  /// Returns [String] SDP mungled with abs-catpure-time header extension.
  static String? setAbsoluteCaptureTime(String? sdp) {
    var id = SdpParser.getAvailableHeaderExtensionIdRange(sdp)[0];
    var header = 'a=extmap:$id '
        'http://www.webrtc.org/experiments/rtp-hdrext/abs-capture-time\r\n';
    var regex =
        RegExp(r'(m=.*\r\n(?:.*\r\n)*?)(a=extmap.*\r\n)', multiLine: true);
    sdp = sdp?.replaceAllMapped(
        regex, (Match match) => '${match[1]}$header${match[2]}');
    _logger.i('Replaced SDP response for setting absolute capture time');
    _logger.d('New SDP value: $sdp');
    return sdp;
  }

  /// Mangle SDP for adding dependency descriptor header extension.
  ///
  /// [sdp] - Current SDP.
  /// Returns [String] SDP mungled with abs-catpure-time header extension.
  static String? setDependencyDescriptor(String? sdp) {
    var id = SdpParser.getAvailableHeaderExtensionIdRange(sdp)[0];
    var header = 'a=extmap:$id '
        'https://aomediacodec.github.io/av1-rtp-spec/#dependency-descriptor-rtp-header-extension\r\n';
    var regex =
        RegExp(r'(m=.*\r\n(?:.*\r\n)*?)(a=extmap.*\r\n)', multiLine: true);
    sdp = sdp?.replaceAllMapped(
        regex, (Match match) => '${match[1]}$header${match[2]}');
    _logger.i('Replaced SDP response for setting depency descriptor');
    _logger.d('New SDP value: $sdp');
    return sdp;
  }

  /// Parse SDP for desired bitrate.
  ///
  /// [sdp] - Current SDP.
  /// [bitrate] - Bitrate value in kbps or 0 for unlimited bitrate.
  /// Returns [String] SDP parsed with desired bitrate.
  static String setVideoBitrate(String? sdp, num bitrate) {
    int? video = 0;
    if (sdp != null) {
      if (bitrate < 1) {
        _logger.i('Remove bitrate restrictions');
        sdp = sdp
            .replaceAll(RegExp(r'b=AS:.*\r\n'), '')
            .replaceAll(RegExp(r'b=TIAS:.*\r\n'), '');
        return sdp;
      } else {
        _logger.i('Setting video bitrate');
        Map<String, dynamic> parsedSdp = parse(sdp);
        video = getMediaId(parsedSdp['media'], 'video');
        if (video == null) {
          return sdp;
        }
        parsedSdp['media'][video]['bandwidth'] = [
          {'type': 'AS', 'limit': bitrate}
        ];
        sdp = write(parsedSdp, null);
        return sdp;
      }
    }
    return '';
  }

  /// Remove SDP line.
  ///
  /// [sdp] - Current SDP.
  /// [sdpLine] - SDP line to remove.
  /// Returns [String] SDP without the line.
  static String? removeSdpLine(String? sdp, String sdpLine) {
    _logger.d('SDP before trimming: ', sdp);
    var sdpList = sdp!.split('\n');
    sdpList.retainWhere((line) {
      return line.trim() != sdpLine;
    });
    sdp = sdpList.join('/n');
    _logger.d('SDP trimmed result: $sdp');
    return sdp;
  }

  /// Replace codec name of a SDP.
  ///
  /// [sdp] - Current SDP.
  /// [codec] - Codec name to be replaced.
  /// [newCodecName] - New codec name to replace.
  /// Returns [String] SDP updated with new codec name.
  static String? adaptCodecName(
      String? sdp, String codec, String newCodecName) {
    if (sdp == null) {
      return sdp;
    }
    var regex = RegExp(codec, caseSensitive: true);
    return sdp.replaceAll(regex, newCodecName);
  }

  /// Parse SDP for support multiopus.
  ///
  /// **Only available in Google Chrome.**
  /// [sdp] - Current SDP.
  /// [mediaStream] - MediaStream offered in the stream.
  /// Returns [String] SDP parsed with multiopus support.
  static setMultiopus(String? sdp, mediaStream) {
    if (sdp == null) {
      return;
    }
    if (hasAudioMultichannel(mediaStream)) {
      if (!sdp.contains('multiopus/48000/6')) {
        _logger.i('Setting multiopus');
        // Find the audio m-line
        RegExp reg1 = RegExp(r'm=audio 9 UDP\/TLS\/RTP\/SAVPF (.*)\n');
        var res = (reg1.allMatches(sdp).map((e) => e[0])).toList();
        // Get audio line
        var audio = res[0];
        // Get free payload number for multiopus
        var pt = getAvailablePayloadTypeRange(sdp)[0];
        // Add multiopus
        if (audio == null) {
          return sdp;
        }
        var multiopus = audio.replaceAll(RegExp(r'\n'), ' ') +
            pt.toString() +
            '\r\n' +
            'a=rtpmap:' +
            pt.toString() +
            ' multiopus/48000/6\r\n' +
            'a=fmtp:' +
            pt.toString() +
            ' channel_mapping=0,4,1,2,3,5;coupled_streams=2;' +
            'minptime=10;num_streams=4;useinbandfec=1\r\n';
        // Change sdp
        sdp = sdp.replaceAll(RegExp(audio), multiopus);
        _logger.i('Multiopus offer created');
        _logger.d('SDP parsed for multioups: ', sdp);
      } else {
        _logger.i('Multiopus already setted');
      }
    }
    return sdp;
  }

  /// Gets all available payload type IDs of the current Session Description.
  ///
  /// [sdp] - Current SDP.
  /// Returns [List] with all available payload type ids.
  static List<num> getAvailablePayloadTypeRange(String? sdp) {
    var regex =
        RegExp(r'm=(?:.*) (?:.*) UDP\/TLS\/RTP\/SAVPF (.*)\n', multiLine: true);

    var matches = regex.allMatches(sdp!);
    List<num> ptAvailable = payloadTypeUppperRange;
    ptAvailable.addAll(payloadTypeLowerRange);
    for (var match in matches) {
      var usedNumbers = match[1]!.split(' ').map((n) => int.parse(n));
      ptAvailable.removeWhere((n) => usedNumbers.contains(n));
    }

    return ptAvailable;
  }

  /// Gets all available header extension IDs of the current Session
  /// Description.
  ///
  /// [sdp] - Current SDP.
  /// Returns [List] of All available header extension IDs.
  static List<num> getAvailableHeaderExtensionIdRange(String? sdp) {
    var regex = RegExp(r'a=extmap:(\d+)(?:.*)\r\n', multiLine: true);
    var matches = regex.allMatches(sdp!);
    headerExtensionIdLowerRange.addAll(headerExtensionIdUppperRange);
    List<num> idAvailable = headerExtensionIdLowerRange;
    for (var match in matches) {
      List<num>? usedNumbers =
          match[1]?.split(' ').map((n) => num.parse(n)).toList();
      // .map((n) => {num.parse(n)});
      idAvailable.retainWhere((num n) {
        return !(usedNumbers!.contains(n));
      });
    }
    return idAvailable;
  }

  /// Renegotiate remote sdp based on previous description.
  ///
  /// This function will fill missing m-lines cloning on the remote
  /// description by cloning the codec and extensions already negotiated
  /// for that media
  ///
  /// [localDescription] - Updated local sdp
  /// [remoteDescription] - Previous remote sdp
  static String? renegotiate(
      String? localDescription, String? remoteDescription) {
    if (localDescription != null && remoteDescription != null) {
      Map<String, dynamic> offer = parse(localDescription);
      Map<String, dynamic> answerRemote = parse(remoteDescription);

      // Check all transceivers on the offer are on the answer
      for (var offeredMedia in offer['media']) {
        Map<String, dynamic> answer = parse(remoteDescription);


        // Get associated mid on the answer
        bool isMidOnAnswer = (answer['media'] as List<dynamic>)
            .any((answerMedia) => answerMedia['mid'] == offeredMedia['mid']);

        // If not found in answer
        if (!isMidOnAnswer) {
          // Find first media line for same kind
          var first = (answer['media'] as List<dynamic>).firstWhere(
              (answerMedia) => answerMedia['type'] == offeredMedia['type']);

          // If found
          if (!first.isEmpty) {

            // Set mid
            first['mid']=offeredMedia['mid'];

            // Set direction
            first['direction']=reverseDirection(offeredMedia['direction']);
            first['ssrcs'] = null;
            first['msid'] = null;
            answerRemote['media'].add(first);
          }
          //Add correct bundle
          answerRemote['groups'][0]['mids'] = offer['groups'][0]['mids'];
        }

      }
      remoteDescription = write(answerRemote, null);
      return remoteDescription;
    } else {
      return localDescription;
    }
  }

  /// Checks if mediaStream has more than 2 audio channels.
  ///
  /// [mediaStream] - MediaStream to verify.
  /// Returns true [bool] if MediaStream has more than 2 channels.
  static bool hasAudioMultichannel(MediaStream mediaStream) {
    mediaStream.getAudioTracks().forEach((element) {
      _logger.w(element);
    });
    return mediaStream.getAudioTracks().length > 2;
  }
}

String reverseDirection(String direction) {
  switch (direction) {
    case 'sendrecv':
      return 'sendrecv';
    case 'sendonly':
      return 'recvonly';
    case 'recvonly':
      return 'sendonly';
    case 'inactive':
      return 'inactive';
    default:
      return 'sendrecv';
  }
}

int? getMediaId(List<dynamic> medias, String type) {
  int? mediaId;
  for (Map media in medias) {
    if (media['type'] == type) {
      mediaId = medias.indexOf(media);
      break;
    }
  }
  return mediaId;
}

List<String> getCodecs(List<Map> media) {
  List<String> codecs = [];
  for (var codec in media) {
    codecs.add(codec['codec']);
  }
  return codecs;
}
