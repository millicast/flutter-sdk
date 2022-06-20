import 'package:flutter_test/flutter_test.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

class MockPublish extends Publish {
  MockPublish({required String streamName, required Function tokenGenerator})
      : super(streamName: streamName, tokenGenerator: tokenGenerator);
  @override
  initConnection(Map data) {
    streamName = 'initConnection was called';
  }
}

void main() {
  late MockPublish mockPublish;
  test('test connect', () async {
    mockPublish = MockPublish(streamName: '', tokenGenerator: () {});
    await mockPublish.connect();
    expect(mockPublish.options, {
      'mediaStream': null,
      'bandwidth': 0,
      'disableVideo': false,
      'disableAudio': false,
      'codec': 'h264',
      'simulcast': false,
      'scalabilityMode': null,
      'peerConfig': null,
      'setSDPToPeer': false
    });
    expect(mockPublish.streamName, 'initConnection was called');
  });

  test('test replaceConnection', () async {
    mockPublish.options = {
      ...?mockPublish.options,
      'mediaStream': 'MyMediaStream'
    };
    await mockPublish.replaceConnection();
    // verify(mockPeerConnection.getTracks()).called(1);
    expect(mockPublish.options, {
      'mediaStream': 'MyMediaStream',
      'bandwidth': 0,
      'disableVideo': false,
      'disableAudio': false,
      'codec': 'h264',
      'simulcast': false,
      'scalabilityMode': null,
      'peerConfig': null,
      'setSDPToPeer': false
    });
    expect(mockPublish.streamName, 'initConnection was called');
  });
}
