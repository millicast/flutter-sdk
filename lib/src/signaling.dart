import 'package:eventify/eventify.dart';
import 'package:millicast_flutter_sdk/src/utils/channel.dart';
import 'package:millicast_flutter_sdk/src/utils/sdp_parser.dart';
import 'utils/transaction_manager.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'logger.dart';
import './utils/sdp_parser.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

var _logger = getLogger('Signaling');

const Map<String, String> videoCodec = {
  'VP8': 'vp8',
  'VP9': 'vp9',
  'H264': 'h264',
  'AV1': 'av1',
};

/// Starts [WebSocketChannel] connection and manages the messages between peers.
///
/// establish a WebRTC connection.
/// ```dart
/// var millicastSignaling = Signaling(options);
/// ```
class Signaling extends EventEmitter {
  /// [streamName] - Millicast stream name to get subscribed.
  String? streamName;

  /// [wsUrl] URL is used to initialize a [webSocket] with Millicast server and
  String wsUrl = 'ws://localhost:8080/';

  WebSocketChannel? webSocket;
  TransactionManager? transactionManager;
  RTCSessionDescription? remoteSdp;

  //flag to stop reconnection if migration is in transit because websocket
  //connection error and connection close trigger the same event(onDone)
  bool? isMigrating = false;

  /// [options] - General signaling options.
  Signaling(Map<String, dynamic> options) {
    streamName = options['streamName'];
    wsUrl = options['url'];
    webSocket = null;
    transactionManager = null;
    remoteSdp = null;
  }

  /// Starts a WebSocket connection with signaling server.
  ///
  /// ```dart
  /// var response = await millicastSignaling.connect();
  /// ```
  /// [WebSocketChannel] Future object which represents the [webSocket]
  /// {https://developer.mozilla.org/en-US/docs/Web/API/WebSockets_API}
  /// of the establshed connection.
  Future<WebSocketChannel> connect() async {
    {
      _logger.i('Connecting to Signaling Server');
      if (webSocket != null && transactionManager != null) {
        _logger.i('Connected to server $wsUrl');
        return webSocket!;
      }
      webSocket = WebSocketChannel.connect(Uri.parse(wsUrl));
      transactionManager = TransactionManager(webSocket!);
      _logger.i('WebSocket opened');
      transactionManager?.on('event', this, (event, context) {
        emit(SignalingEvents.broadcastEvent, this, event.eventData);
      });
      transactionManager?.on(SignalingEvents.connectionError, this,
          (event, context) {
        if (isMigrating == false) {
          emit(SignalingEvents.connectionError, this, event);
          throw Exception(event);
        }
      });
      transactionManager?.on(SignalingEvents.connectionClose, this,
          (event, context) {
        webSocket = null;
        transactionManager = null;
        _logger.i('Connection closed with Signaling Server.');
        emit(SignalingEvents.connectionClose, this, event);
      });
      emit(SignalingEvents.connectionSuccess, this,
          {'ws': webSocket, 'tm': transactionManager});
      return webSocket!;
    }
  }

  /// Close WebSocket connection with Millicast server.
  ///
  /// ```dart
  /// millicastSignaling.close();
  /// ```
  void close() {
    _logger.i('Closing connection with Signaling Server.');
    transactionManager?.close();
  }

  /// Establish WebRTC connection with Millicast Server as Subscriber role.
  ///
  /// [sdp] - The SDP information created by your offer.
  /// [options] - Signaling Subscribe Options.
  /// Returns [Future] object which represents the SDP command response.
  ///
  /// ```dart
  /// var response = await millicastSignaling.subscribe(sdp)
  /// ```
  Future<String> subscribe(String sdp, {Map<String, dynamic>? options}) async {
    _logger.i('Starting subscription to streamName: $streamName');
    _logger.d('Subscription local description: $sdp');
    String? sdpString =
        SdpParser.adaptCodecName(sdp, 'AV1X', videoCodec['AV1']!);
    Map<String, dynamic> data = {
      'sdp': sdpString,
      'streamId': streamName,
      'pinnedSourceId': options?['pinnedSourceId'],
      'excludedSourceIds': options?['excludedSourceIds']
    };
    if (options != null) {
      if (options['vad'] != null) {
        data['vad'] = true;
      }
      if (options['events'] != null) {
        data['events'] = options['events'];
      }
    }
    try {
      await connect();
      _logger.i('Sending view command');
      var result = await transactionManager?.cmd('view', data);
      return result['data']['sdp'];
    } catch (e) {
      _logger.e('Error sending view command, error: $e');
      throw Exception(e);
    }
  }

  /// Establish WebRTC connection with Millicast Server as Publisher role.
  ///
  /// [sdp] - The SDP information created by your offer.
  /// [options] - Signaling Publish Options.
  /// Returns Future object which represents the SDP command response.
  /// ```dart
  /// var response = await millicastSignaling.publish(sdp, {codec: 'h264'})
  /// ```
  Future<String> publish(String? sdp, {Map<String, dynamic>? options}) async {
    _logger.i('Starting publishing to streamName: '
        '$streamName, codec: ${options?['codec']}');
    _logger.d('Publishing local description: $sdp');
    if (options != null) {
      if (!videoCodec.containsValue(options['codec'])) {
        _logger.e('Invalid codec. Possible values are: $videoCodec');
        throw Exception('Invalid codec. Possible values are: $videoCodec');
      }
      List<String?> codecs = (await NativeChannel.supportedCodecs);
      if (!codecs.contains(options['codec'])) {
        options['codec'] = codecs[0];
        _logger
            .w('Codec not supported by this device. Fallback to: ${codecs[0]}');
      }
      if (options['codec'] == videoCodec['AV1']) {
        sdp = SdpParser.adaptCodecName(sdp, 'AV1X', videoCodec['AV1']!);
      }
    }
    Map data = {
      'name': streamName,
      'sdp': sdp,
      'codec': options?['codec'],
      'sourceId': options?['sourceId']
    };
    if (options?['record'] != null) {
      data['record'] = options?['record'];
    }
    if (options?['events'] != null) {
      data['events'] = options?['events'];
    }
    try {
      await connect();
      _logger.i('Sending publish command');
      var result = await transactionManager?.cmd('publish', data);
      return result['data']['sdp'];
    } catch (e) {
      _logger.e('Error sending publish command, error: $e');
      throw Exception(e);
    }
  }

  /// Send command to the server.
  ///
  /// [cmd] - Command name.
  /// [data] - Command parameters.
  /// Returns a Future object which represents the command response.
  cmd(String cmd, Object data) async {
    _logger.i('Sending cmd: $cmd');
    transactionManager?.cmd(cmd, data);
  }
}

abstract class SignalingEvents {
  static String connectionSuccess = 'wsConnectionSuccess';
  static String connectionError = 'wsConnectionError';
  static String connectionClose = 'wsConnectionClose';
  static String broadcastEvent = 'broadcastEvent';
}

abstract class AudioCodec {
  static const String opus = 'opus';
  static const String multiopus = 'multiopus';
}

class LayerInfo {
  String encodingId;
  num spatialLayerId;
  num temporalLayerId;
  num maxSpatialLayerId;
  num maxTemporalLayerId;

  LayerInfo(
      {required this.encodingId,
      required this.spatialLayerId,
      required this.temporalLayerId,
      required this.maxSpatialLayerId,
      required this.maxTemporalLayerId});
}
