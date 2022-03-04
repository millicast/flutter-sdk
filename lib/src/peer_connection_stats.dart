import 'dart:async';

import 'package:eventify/eventify.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

import 'logger.dart';

var _logger = getLogger('PeerConnectionStats');
const Map<String, dynamic> peerConnectionStatsEvents = {'stats': 'stats'};

class PeerConnectionStats extends EventEmitter {
  ConnectionStats? stats;
  RTCPeerConnection peer;
  Timer? emitInterval;
  ConnectionStats? previousStats;

  PeerConnectionStats(this.peer);

  /// Initialize the statistics monitoring of the RTCPeerConnection.
  init() {
    _logger.i('Initializing peer connection stats');
    emitInterval =
        Timer.periodic(const Duration(milliseconds: 1000), (timer) async {
      _logger.d('New interval executed');
      List<StatsReport> stats = await peer.getStats();
      parseStats(stats);
      _logger.d('Emitting stats');
      emit(peerConnectionStatsEvents['stats'], this, stats);
    });
  }

  parseStats(List<StatsReport> rawStats) {
    _logger.d('Parsing raw stats');
    previousStats = stats;
    ConnectionStats statsObject = ConnectionStats.fromJson({
      'audio': {'inbounds': [], 'outbounds': []},
      'video': {'inbounds': [], 'outbounds': []},
      'raw': rawStats
    });

    for (StatsReport report in rawStats) {
      switch (report.type) {
        case 'outbound-rtp':
          {
            addOutboundRtpReport(
                report.values, previousStats ?? stats, statsObject);
            break;
          }
        case 'inbound-rtp':
          {
            addInboundRtpReport(
                report.values, previousStats ?? stats, statsObject);
            break;
          }
        case 'candidate-pair':
          {
            if (report.values['nominated']) {
              addCandidateReport(report.values, statsObject);
            }
            break;
          }
        default:
          break;
      }
    }
    stats = statsObject;
  }

  stop() {
    _logger.i('Stopping peer connection stats');
    emitInterval?.cancel();
  }

  /// Parse and add incoming outbound-rtp report from RTCPeerConnection
  /// to final report.
  ///
  /// stats.
  /// [report] - JSON object which represents a report from RTCPeerConnection
  /// [previousStats] - Previous stats parsed.
  /// [statsObject] - Current stats object being parsed.
  addOutboundRtpReport(
      Map report, ConnectionStats? previousStats, ConnectionStats statsObject) {
    _logger.d('Parsing outbound-rtp report');
    String mediaType = getMediaType(report);
    var codecInfo = getCodecData(report['codecId'], statsObject['raw']) ?? {};
    var additionalData =
        getBaseRtpReportData(report as Map<String, dynamic>, mediaType);
    additionalData['totalBytesSent'] = report['bytesSent'];
    additionalData['id'] = report['id'];
    var previousBytesSent;
    if ((previousStats != null)) {
      previousBytesSent = previousStats[mediaType]['outbounds'].firstWhere(
              (x) => x['id'] == additionalData['id'])?['totalBytesSent'] ??
          0;
    } else {
      previousBytesSent = null;
    }
    additionalData['bitrate'] = previousBytesSent != null
        ? 8 * (report['bytesSent'] - previousBytesSent)
        : 0;

    if (mediaType == 'video') {
      additionalData['qualityLimitationReason'] =
          report['qualityLimitationReason'];
      statsObject[mediaType].outbounds.add({...codecInfo, ...additionalData});
    }
  }

  /// Parse and add incoming inbound-rtp report from RTCPeerConnection
  /// to final report.
  ///
  /// [report] - JSON object which represents a report from
  /// RTCPeerConnection stats.
  /// [previousStats] - Previous stats parsed.
  /// [statsObject] - Current stats object being parsed.
  addInboundRtpReport(
      Map report, ConnectionStats? previousStats, ConnectionStats statsObject) {
    _logger.d('Parsing inbound-rtp report');
    String mediaType = getMediaType(report);
    Map codecInfo = getCodecData(report['codecId'], report);

    // Safari is missing mediaType and kind for 'inbound-rtp';
    if (mediaType != 'audio' || mediaType != 'video') {
      if (report['id'] == 'Video') {
        mediaType = 'video';
      } else {
        mediaType = 'audio';
      }
    }
    var additionalData = getBaseRtpReportData(report, mediaType);
    additionalData['totalBytesReceived'] = report['bytesReceived'];
    additionalData['totalPacketsReceived'] = report['packetsReceived'];
    additionalData['totalPacketsLost'] = report['packetsLost'];
    additionalData['jitter'] = report['jitter'];
    additionalData['id'] = report['id'];

    additionalData['bitrate'] = 0;
    additionalData['packetsLostRatioPerSecond'] = 0;
    additionalData['packetsLostDeltaPerSecond'] = 0;
    if (previousStats != null) {
      var previousReport = previousStats[mediaType]['inbounds']
          .firstWhere((x) => x['id'] == additionalData['id'], orElse: null);
      if (previousReport != null) {
        num previousBytesReceived = previousReport['totalBytesReceived'];
        additionalData['bitrate'] =
            8 * (report['bytesReceived'] - previousBytesReceived);
        additionalData['packetsLostRatioPerSecond'] =
            calculatePacketsLostRatio(additionalData, previousReport);
        additionalData['packetsLostDeltaPerSecond'] =
            calculatePacketsLostDelta(additionalData, previousReport);
      }
    }

    statsObject[mediaType]['inbounds'].add({...codecInfo, ...additionalData});
  }

  /// Parse and add incoming candidate-pair report from RTCPeerConnection
  /// to final report.
  /// Also adds associated local-candidate data to report.
  ///
  /// [report] - JSON object which represents a report from
  /// RTCPeerConnection stats.
  /// [statsObject] - Current stats object being parsed.
  addCandidateReport(
      Map<dynamic, dynamic> report, ConnectionStats statsObject) {
    _logger.d('Parsing candidate-pair report');
    statsObject.totalRoundTripTime = report['totalRoundTripTime'] as double?;
    statsObject.currentRoundTripTime =
        report['currentRoundTripTime'] as double?;
    statsObject.availableOutgoingBitrate =
        report['availableOutgoingBitrate'] as double?;
    statsObject.candidateType = statsObject.raw
        ?.firstWhere(
            (element) => element.values.keys.contains('localCandidateId'))
        .values['candidateType'] as String?;
  }

  /// Get media type.
  ///
  /// [report] - JSON object which represents a report from RTCPeerConnection
  /// stats.
  /// Returns Media type.
  getMediaType(Map report) {
    return (report['mediaType'] ?? report['kind']);
  }

  /// Get codec information from stats.
  ///
  /// [codecReportId] - Codec report ID.
  /// [rawStats] - RTCPeerConnection stats.
  /// Returns Object containing codec information.
  getCodecData(String? codecReportId, Map rawStats) {
    // ignore: prefer_typing_uninitialized_variables
    var mime;
    if (codecReportId != null) {
      mime = rawStats.values.firstWhere((element) => element == 'codecReportId',
          orElse: () => {});
    } else {
      mime = {};
    }
    return mime['mimeType'] ?? {};
  }

  /// Get common information for RTP reports.
  ///
  /// [report] - JSON object which represents a report from
  /// RTCPeerConnection stats.
  /// [mediaType] - Media type.
  /// Returns Object containing common information.
  Map getBaseRtpReportData(Map<dynamic, dynamic> report, String mediaType) {
    var additionalData = {};
    if (mediaType == 'video') {
      additionalData['framesPerSecond'] = report['framesPerSecond'];
      additionalData['frameHeight'] = report['frameHeight'];
      additionalData['frameWidth'] = report['frameWidth'];
    }
    additionalData['timestamp'] = report['timestamp'];
    return additionalData;
  }

  /// Calculate the ratio packets lost.
  ///
  /// [actualReport] - JSON object which represents a parsed report.
  /// [previousReport] - JSON object which represents a parsed report.
  /// Returns Packets lost ratio
  calculatePacketsLostRatio(Map<dynamic, dynamic> actualReport,
      Map<dynamic, dynamic> previousReport) {
    num currentLostPackages =
        calculatePacketsLostDelta(actualReport, previousReport);
    num currentReceivedPackages = actualReport['totalPacketsReceived'] -
        previousReport['totalPacketsReceived'];
    return currentLostPackages / currentReceivedPackages;
  }

  /// Calculate the delta packets lost.
  ///
  /// [actualReport] - JSON object which represents a parsed report.
  /// [previousReport] - JSON object which represents a parsed report.
  /// Returns Packets lost ratio
  num calculatePacketsLostDelta(Map<dynamic, dynamic> actualReport,
      Map<dynamic, dynamic> previousReport) {
    return (actualReport['totalPacketsLost'] as num) -
        (previousReport['totalPacketsLost'] as num);
  }
}

///
class ConnectionStats {
  /// [raw] - All RTCPeerConnection stats without parsing.
  /// Reference {https://developer.mozilla.org/en-US/docs/Web/API/RTCStatsReport}.
  List<StatsReport>? raw;

  /// [audio] - Parsed audio information.
  Map<String, List<dynamic>>? audio;

  /// [video] - Parsed video information.
  Map<String, List<dynamic>>? video;

  /// [availableOutgoingBitrate] - The available outbound capacity of the network
  /// connection. The higher the value, the more bandwidth you can assume is
  /// available for outgoing data. The value is reported in bits per second.
  /// This value comes from the nominated candidate-pair.
  double? availableOutgoingBitrate;

  /// [totalRoundTripTime] - Total round trip time is the total time in seconds
  /// that has elapsed between sending STUN requests and receiving the responses.
  /// This value comes from the nominated candidate-pair.
  double? totalRoundTripTime;

  /// [currentRoundTripTime] - Current round trip time indicate the number of
  /// seconds it takes for data to be sent by this peer to the remote peer and
  /// back over the connection described by this pair of ICE candidates.
  /// This value comes from the nominated candidate-pair.
  double? currentRoundTripTime;

  /// [candidateType] - Local candidate type from the nominated candidate-pair
  /// which indicates the type of ICE candidate the object represents.
  String? candidateType;

  ConnectionStats(
      {this.raw,
      this.audio,
      this.video,
      this.availableOutgoingBitrate,
      this.totalRoundTripTime,
      this.currentRoundTripTime,
      this.candidateType});

  factory ConnectionStats.fromJson(Map<String, dynamic> json) {
    try {
      return ConnectionStats(
          raw: json['raw'],
          audio: json['audio'],
          video: json['video'],
          availableOutgoingBitrate: json['availableOutgoingBitrate'],
          totalRoundTripTime: json['totalRoundTripTime'],
          currentRoundTripTime: json['currentRoundTripTime'],
          candidateType: json['candidateType']);
    } catch (e) {
      throw Exception(e);
    }
  }
  dynamic operator [](prop) {
    switch (prop) {
      case 'raw':
        return raw;
      case 'audio':
        return audio;
      case 'video':
        return video;
      case 'availableOutgoingBitrate':
        return availableOutgoingBitrate;
      case 'totalRoundTripTime':
        return totalRoundTripTime;
      case 'currentRoundTripTime':
        return currentRoundTripTime;
      case 'candidateType':
        return candidateType;
      default:
    }
  }
}
