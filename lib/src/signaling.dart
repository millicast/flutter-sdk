import 'package:eventify/eventify.dart';
// import 'package:millicast_flutter_sdk/src/utils/sdp_parser.dart';
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

class Signaling extends EventEmitter {
  String? streamName;
  String wsUrl = 'ws://localhost:8080/';
  WebSocketChannel? webSocket;
  TransactionManager? transactionManager;
  RTCSessionDescription? remoteSdp;

  Signaling(Map<String, dynamic> options) {
    streamName = options['streamName'];
    wsUrl = options['url'];
    webSocket = null;
    transactionManager = null;
    remoteSdp = null;
  }

  Future<WebSocketChannel?> connect() async {
    {
      _logger.i('Connecting to Signaling Server');
      if (webSocket != null && transactionManager != null) {
        _logger.i('Connected to server $wsUrl');
        return webSocket;
      }
      webSocket = WebSocketChannel.connect(Uri.parse(wsUrl));
      transactionManager = TransactionManager(webSocket!);
      _logger.i('WebSocket opened');
      transactionManager?.on('event', this, (event, context) {
        emit(SignalingEvents.broadcastEvent, event);
      });
      emit(SignalingEvents.connectionSuccess,
          {'ws': webSocket, 'tm': transactionManager});
      return webSocket;
    }
  }

  void close() {}

  subscribe(RTCSessionDescription sdp,
      {SignalingSubscribeOptions? options}) async {
    _logger.i('Starting subscription to streamName: $streamName');
    _logger.d('Subscription local description: $sdp');
    String? sdpString =
        SdpParser.adaptCodecName(sdp, 'AV1X', videoCodec['AV1']!);
    Map<String, dynamic> data = {
      'sdp': sdpString,
      'streamId': streamName,
      'pinnedSourceId': options?.pinnedSourceId,
      'excludedSourceIds': options?.excludedSourceIds
    };
    if (options != null) {
      if (options.vad!) {
        data['vad'] = true;
      }
      if (options.events != null) {
        data['events'] = options.events;
      }
    }
    try {
      await connect();
      _logger.i('Sending view command');
      int transId = await transactionManager?.cmd('view', data);
      Map<int, Listener?> transactions = {};
      transactions[transId] =
          transactionManager?.on('response', this, (event, context) {
        dynamic data = event.eventData;
        emit('remoteSdp', this, data['data']['sdp']);
        transactions[context]?.cancel();
      });
      // Check if browser supports AV1X
      // var AV1X = RTCRtpReceiver.getCapabilities?.('video')?.codecs?.find?.(codec => codec.mimeType === 'video/AV1X')
      // ignore: lines_longer_than_80_chars
      // Signaling server returns 'AV1'. If browser supports AV1X, we change it to AV1X
      // if (AV1X) {
      // ignore: lines_longer_than_80_chars
      // result.sdp = SdpParser.adaptCodecName(result.sdp, VideoCodec.av1, 'AV1X');
      // } else {
      // result.sdp = result.sdp;
      // }
    } catch (e) {
      _logger.e('Error sending view command, error: $e');
      throw Exception(e);
    }
  }

  Future publish(RTCSessionDescription sdp,
      {SignalingPublishOptions? options}) async {
    _logger.i(
        // ignore: lines_longer_than_80_chars
        'Starting publishing to streamName: $streamName, codec: ${options?.codec}');
    _logger.d('Publishing local description: $sdp');
    if (options != null) {
      if (!videoCodec.containsValue(options.codec)) {
        _logger.e('Invalid codec. Possible values are: $videoCodec');
        throw Exception('Invalid codec. Possible values are: $videoCodec');
        // Signaling server only recognizes 'AV1' and not 'AV1X'
      }
      if (options.codec == videoCodec['AV1']) {
        sdp.sdp = SdpParser.adaptCodecName(sdp, 'AV1X', videoCodec['AV1']!);
      }
    }
    Map data = {
      'name': streamName,
      'sdp': sdp.sdp,
      'codec': options?.codec,
      'sourceId': options?.sourceId
    };
    if (options?.record != null) {
      data['record'] = options?.record;
    }
    try {
      await connect();
      _logger.i('Sending publish command');
      int transId = await transactionManager?.cmd('publish', data);
      Map<int, Listener?> transactions = {};
      transactions[transId] =
          transactionManager?.on('response', this, (event, context) {
        dynamic data = event.eventData;
        emit('remoteSdp', this, data['data']['sdp']);
        transactions[context]?.cancel();
      });

      // if (options.codec == videoCodec['AV1']) {
      //   // If browser supports AV1X, we change from AV1 to AV1X
      //   const AV1X = RTCRtpSender.getCapabilities?.('video')?.codecs?.find?.(codec => codec.mimeType === 'video/AV1X');
      // ignore: lines_longer_than_80_chars
      //   result['sdp'] = AV1X ? SdpParser.adaptCodecName(result.sdp, videoCodec['AV1']!, 'AV1X') : result.sdp;
      // }
      return;
    } catch (e) {
      _logger.e('Error sending publish command, error: $e');
      throw Exception(e);
    }
  }

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

class SignalingSubscribeOptions {
  bool? vad;
  String? pinnedSourceId;
  List<String>? excludedSourceIds;
  List<String>? events;
  LayerInfo? layer;
  SignalingSubscribeOptions({
    this.vad,
    this.pinnedSourceId,
    this.excludedSourceIds,
    this.events,
    this.layer,
  });

  factory SignalingSubscribeOptions.fromJson(Map<String, dynamic> json) {
    try {
      return SignalingSubscribeOptions(
        vad: json['vad'],
        pinnedSourceId: json['pinnedSourceId'],
        excludedSourceIds: json['excludedSourceIds'],
        events: json['events'],
        layer: json['layer'],
      );
    } catch (e) {
      throw Exception(e);
    }
  }
}

class SignalingPublishOptions {
  String codec;
  bool? record;
  String? sourceId;

  SignalingPublishOptions({
    this.codec = 'h264',
    this.record,
    this.sourceId,
  });
}
