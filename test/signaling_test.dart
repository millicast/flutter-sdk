import 'package:millicast_flutter_sdk/src/utils/sdp_parser.dart';
import 'package:millicast_flutter_sdk/src/utils/transaction_manager.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'mocks/signaling_test.mocks.dart';
import 'mocks/sdp_mock.dart';

@GenerateMocks([TransactionManager, WebSocketChannel])
void main() {
  Signaling signaling = Signaling({'streamName': '', 'url': ''});
  TransactionManager mockTransactionManager = MockTransactionManager();
  MockWebSocketChannel mockWebSocketChannel = MockWebSocketChannel();

  signaling.transactionManager = mockTransactionManager;
  signaling.webSocket = mockWebSocketChannel;

  group('Signaling tests:', () {
    test('close signaling', () {
      when(mockTransactionManager.close()).thenReturn(null);
      signaling.close();
      verify(mockTransactionManager.close()).called(1);
    });

    test('connect with an existing webSocket', () async {
      WebSocketChannel response = await signaling.connect();
      expect(response, mockWebSocketChannel);
    });

    test('subscribe with sdp', () async {
      when(mockTransactionManager.cmd(any, any))
          .thenAnswer((realInvocation) async {
        return {
          'data': {
            'sdp': SdpParser.adaptCodecName(sdp, 'AV1X', videoCodec['AV1']!),
            'streamId': '',
            'pinnedSourceId': '',
            'excludedSourceIds': ''
          }
        };
      });

      await signaling.subscribe(sdp);

      verify(mockTransactionManager.cmd(any, any));
    });

    test('subscribe with an error thrown', () async {
      when(mockTransactionManager.cmd(any, any)).thenThrow(Exception());

      expect(() => signaling.subscribe(sdp), throwsA(isA<Exception>()));
    });

    test('publish with sdp', () async {
      when(mockTransactionManager.cmd(any, any))
          .thenAnswer((realInvocation) async {
        return {
          'data': {
            'sdp': SdpParser.adaptCodecName(sdp, 'AV1X', videoCodec['AV1']!),
            'streamId': '',
            'pinnedSourceId': '',
            'excludedSourceIds': ''
          }
        };
      });

      await signaling.publish(sdp);

      verify(mockTransactionManager.cmd(any, any));
    });

    test('publish with an error thrown', () async {
      when(mockTransactionManager.cmd(any, any)).thenThrow(Exception());

      expect(() => signaling.publish(sdp), throwsA(isA<Exception>()));
    });
  });
}
