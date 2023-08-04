import 'package:millicast_flutter_sdk/src/utils/fetch_error.dart';

import 'config.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'logger.dart';

String liveWebSocketDomain = '';
const String defaultApiEndpoint = Config.millicastDirectorEndpoint;
String apiEndpoint = defaultApiEndpoint;

var _logger = getLogger('Director');

/// Simplify API calls to find the best server and region to publish and
/// subscribe to.
///
/// For security reasosn all calls will return a [JWT](https://jwt.io) token
/// from authentication including the required socket path to connect with.
/// You will need your own Publishing token and Stream name, please refer to
/// [Managing Your Tokens](https://dash.millicast.com/docs.html?pg=managing-your-tokens).
class Director {
  /// Set Director API endpoint where requests will be sent.
  ///
  /// [url] - New Director API endpoint
  /// ```dart
  /// import 'package:millicast_flutter_sdk/src/director.dart';
  /// void main() {
  ///   String endpoint = '';
  ///   endpoint = Director.getEndpoint();
  ///   Director.setEndpoint('https://my.api.endpoint.com/');
  ///   endpoint = Director.getEndpoint(); // https://my.api.endpoint.com
  /// }
  /// ```
  static void setEndpoint(String url) {
    var matchLastSlash = RegExp(r'/$');
    apiEndpoint = url.replaceAll(matchLastSlash, '');
  }

  /// Get current Director API endpoint where requests will be sent.
  ///
  /// By default, https://director.millicast.com is the current API endpoint.
  /// Returns API base url
  static String getEndpoint() {
    return apiEndpoint;
  }

  /// Set Websocket Live domain from Director API response.
  ///
  /// If it is set to empty, it will not parse the response.
  /// [domain] - New Websocket Live domain
  /// ```dart
  /// void main() {
  ///   String liveDomain = '';
  ///   liveDomain = Director.getLiveDomain();
  ///   Director.setLiveDomain('https://my.livedomain.com/');
  ///   liveDomain = Director.getLiveDomain(); // 'https://my.livedomain.com'
  /// }
  static void setLiveDomain(String domain) {
    var matchLastSlash = RegExp(r'/$');
    liveWebSocketDomain = domain.replaceAll(matchLastSlash, '');
  }

  /// Get current Websocket Live domain.
  ///
  /// By default is empty which corresponds to not parse the Director response.
  /// Returns Websocket Live domain
  static String getLiveDomain() {
    return liveWebSocketDomain;
  }

  /// Get publisher connection data.
  ///
  /// [options] - Millicast options.
  /// Returns [Future] object which represents the result of getting the
  /// publishing connection path.
  ///
  /// ```dart
  /// import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
  /// void main() async {
  ///   tokenGenerator() => Director.getPublisher(DirectorPublisherOptions(
  ///       token: 'Valid Token', streamName: 'Valid Token Name'));
  ///   MillicastDirectorResponse token = await tokenGenerator();
  ///   // Use token
  ///   print(token);
  /// }
  /// ```
  static Future<MillicastDirectorResponse> getPublisher(
      DirectorPublisherOptions options) async {
    http.Client client = options.client ?? http.Client();
    _logger.i(
        '''Getting publisher connection path for stream name: ${options.streamName}''');
    Map<String, dynamic> payload = {
      'streamName': options.streamName,
      'streamType': options.streamType ?? StreamTypes.webRTC
    };
    var url = Uri.parse('${getEndpoint()}/api/director/publish');
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
      HttpHeaders.authorizationHeader: 'Bearer ${options.token}'
    };
    try {
      http.Response response = await client.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );
      _logger.i(response.body);
      final Map<String, dynamic> responseBody =
          jsonDecode(response.body)['data'];
      // Handle a failed POST request
      if (response.statusCode != 200) {
        final error = FetchException(responseBody['message'], 
                                      response.statusCode);
        throw error;
      }
      MillicastDirectorResponse data =
          MillicastDirectorResponse.fromJson(responseBody);
      parseIncomingDirectorResponse(data);
      _logger.d('Getting publisher response:${response.body}');
      return data;
    } catch (e) {
      _logger.e('Error while getting publisher connection path:$e');
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Get subscriber connection data.
  ///
  /// [options] - Millicast options.
  /// Returns Future object which represents the result of getting the
  /// subscribe connection data.
  ///
  /// ```dart
  /// import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
  /// void main() async {
  ///   tokenGenerator() => Director.getSubscriber(DirectorSubscriberOptions(
  ///       streamAccountId: 'Valid StreamId', streamName: 'Valid StreamName'));
  ///   MillicastDirectorResponse token = await tokenGenerator();
  ///   // Use token
  ///   print(token);
  /// }
  /// ```
  static Future<MillicastDirectorResponse> getSubscriber(
      DirectorSubscriberOptions options) async {
    http.Client client = options.client ?? http.Client();
    _logger.i(
        '''Getting subscriber connection data for stream name: ${options.streamName} and account id: ${options.streamAccountId}''');
    Map<String, dynamic> payload = {
      'streamAccountId': options.streamAccountId,
      'streamName': options.streamName
    };
    var url = Uri.parse('${getEndpoint()}/api/director/subscribe');
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    if (options.subscriberToken != null) {
      // Cast to string as subscriberToken may be null
      String subscriberToken = options.subscriberToken as String;
      headers[HttpHeaders.authorizationHeader] = 'Bearer $subscriberToken';
    }
    _logger.i(payload);
    try {
      http.Response response = await client.post(
        url,
        headers: headers,
        body: jsonEncode(payload),
      );
      _logger.i(jsonDecode(response.body));
      final Map<String, dynamic> responseBody =
          jsonDecode(response.body)['data'];
      // Handle a failed POST request
      if (response.statusCode != 200) {
        final error = FetchException(responseBody['message'], 
                                      response.statusCode);
        throw error;
      }
      MillicastDirectorResponse data =
          MillicastDirectorResponse.fromJson(responseBody);
      parseIncomingDirectorResponse(data);
      _logger.d('Getting subscriber response:${response.body}');
      return data;
    } catch (e) {
      _logger.e('Error while getting subscriber connection path:$e');
      rethrow;
    } finally {
      client.close();
    }
  }

  /// Modifies domain of subscriber/publisher Director reponses
  /// with liveWebSocketDomain value.
  ///
  /// Recieves a [directorResponse] and parses it's urls.
  /// Then it modifies their domain with the [liveWebSocketDomain] value.
  /// ```dart
  /// import 'package:millicast_flutter_sdk/src/director.dart';
  /// void main() {
  ///   Director.setLiveDomain('custom-live-domain.millicast.com/');
  ///   var response = MillicastDirectorResponse(jwt: 'validToken', urls: [
  ///     'wss://default-live-domain.com'
  ///     '/ws/v/sub/abf4edb5833a463d87c3f23ae891d3ed'
  ///   ]);
  ///   var parsedResponse = Director.parseIncomingDirectorResponse(response);
  /// }
  /// ```
  static MillicastDirectorResponse parseIncomingDirectorResponse(
      MillicastDirectorResponse directorResponse) {
    if (liveWebSocketDomain.isNotEmpty) {
      var matchDomain = RegExp(r'//(.*?)/');
      for (String item in directorResponse.urls) {
        RegExpMatch matched = matchDomain.allMatches(item).first;
        int index = directorResponse.urls.indexOf(item);
        if (matched.group(1) != null) {
          item = item.replaceAll(
              RegExp(matched.group(1) as String), Director.getLiveDomain());
        }
        directorResponse.urls[index] = item;
      }
    }
    return directorResponse;
  }
}

class MillicastDirectorResponse {
  String jwt;
  List<dynamic> urls;

  MillicastDirectorResponse({
    required this.jwt,
    required this.urls,
  });

  factory MillicastDirectorResponse.fromJson(Map<String, dynamic> json) {
    try {
      return MillicastDirectorResponse(jwt: json['jwt'], urls: json['urls']);
    } catch (e) {
      throw Exception(e);
    }
  }
}

class DirectorSubscriberOptions {
  /// Millicast publisher Stream Name.
  String streamName;

  /// Millicast Account ID.
  String streamAccountId;

  /// Token to subscribe to secure streams. If you are subscribing to an
  /// unsecure stream, you can omit this param.
  String? subscriberToken;
  http.Client? client;

  DirectorSubscriberOptions({
    required this.streamName,
    required this.streamAccountId,
    this.subscriberToken,
    this.client,
  });
}

class DirectorPublisherOptions {
  /// Millicast Publishing Token.
  String token;

  /// Millicast publisher Stream Name.
  String streamName;

  /// Millicast Stream Type.
  String? streamType;

  /// http Client used to communicate with server.
  http.Client? client;

  DirectorPublisherOptions(
      {required this.token,
      required this.streamName,
      this.client,
      this.streamType});
}

abstract class StreamTypes {
  static const String webRTC = 'WebRtc';
  static const String rtmp = 'Rtmp';
}
