import 'package:flutter_dotenv/flutter_dotenv.dart';

class Constants {
  static String streamName =
      dotenv.env['MILLICAST_STREAM_NAME'] ?? 'testStramName';
  static String accountId =
      dotenv.env['MILLICAST_ACCOUNT_ID'] ?? 'testAccountId';
  static String publishToken =
      dotenv.env['MILLICAST_PUBLISH_TOKEN'] ?? 'testPublishToken';

  static Map<String, dynamic> topicRequest = {
    'arguments': [
      ['$accountId/$streamName']
    ],
    'invocationId': '0',
    'streamIds': [],
    'target': 'SubscribeViewerCount',
    'type': 1
  };

  static const Map<String, dynamic> rtcPeerConf = <String, dynamic>{
    'rtcpMuxPolicy': 'require',
    'bundlePolicy': 'max-bundle'
  };
  static const Map<String, dynamic> offerSdpConstraints = <String, dynamic>{
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    }
  };
}
