export 'src/director.dart';
export 'src/logger.dart';
export 'src/peer_connection.dart';
export 'src/publish.dart';
export 'src/signaling.dart';
export 'src/stream_events.dart';
export 'src/view.dart';
import 'src/peer_connection.dart';
export 'src/utils/event_subscriber.dart'; //FOR E2E TESTING, WILL BE REMOVED

void main(List<String> args) async {
  PeerConnection peerConnection = PeerConnection();
  peerConnection.getRTCPeerStatus();
  peerConnection.createRTCPeer();
  await peerConnection.getRTCLocalSDP();
}
