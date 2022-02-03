import 'logger.dart';

var _logger = getLogger('PeerConnectionStats');
const Map<String, dynamic> peerConnectionStatsEvents = {'stats': 'stats'};

class PeerConnectionStats {
  String? stats;
  String peer;
  String? emitInterval;
  String? previousStats;

  PeerConnectionStats(this.peer);

  void init() {}
  void parseStats(Object rawStats) {}
  void stop() {}

  void addOutboundRtpReport(
      Object report, PeerConnectionStats previousStats, Object statsObject) {}
  void addInboundRtpReport(
      Object report, PeerConnectionStats previousStats, Object statsObject) {}
  void addCandidateReport(Object report, Object statsObject) {}
  String getMediaType(Object report) {
    return '';
  }

  Object getCodecData(String codecReportId, Object rawStats) {
    return '';
  }

  Object getBaseRtpReportData(Object report, String mediaType) {
    return '';
  }

  num calculatePacketsLostRatio(Object actualReport, Object previousReport) {
    return 1;
  }

  num calculatePacketsLostDelta(Object actualReport, Object previousReport) {
    return 1;
  }
}
