import 'logger.dart';

var _logger = getLogger('Director');

/// Simplify API calls to find the best server and region to publish and subscribe to.
/// For security reasosn all calls will return a [JWT](https://jwt.io) token forn authentication including the required
/// socket path to connect with.
///
/// You will need your own Publishing token and Stream name, please refer to [Managing Your Tokens](https://dash.millicast.com/docs.html?pg=managing-your-tokens).
/// @namespace
class Director {
  static void setEndpoint(String url) {}

  static String getEndpoint() {
    return '';
  }

  static void setLiveDOmain(String domain) {}

  static String getLiveDomain() {
    return '';
  }

  static getPublisher(String options, {String streamType = 'WebRtc'}) async {}

  static getSubscriber(String options,
      [String streamAccountId = '', String subscriberToken = '']) async {}

  String Function(
          String options, String legacyStreamName, String legacyStreamType)
      // ignore: prefer_function_declarations_over_variables
      getPublisherOptions =
      (String options, String legacyStreamName, String legacyStreamType) {
    return '';
  };

  String Function(
          String options,
          String legacyStreamAccountId,
          // ignore: prefer_function_declarations_over_variables
          String legacySubscriberToken) getSubscriberOptions =
      (String options, String legacyStreamAccountId,
          String legacySubscriberToken) {
    return '';
  };

  // ignore: prefer_function_declarations_over_variables
  String Function(String directorResponse) parseIncomingDirectorResponse = (
    String directorResponse,
  ) {
    return '';
  };
}
