import 'package:eventify/eventify.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
import 'dart:async';

const int maxReconnectionInterval = 32000;
const int baseInterval = 1000;

const Map<String, dynamic> connectOptions = {
  'disableVideo': false,
  'disableAudio': false,
  'peerConfig': null
};

class BaseWebRTC extends EventEmitter {
  /// [streamName] - Millicast existing stream name.
  String streamName;

  /// [tokenGenerator] - Callback function executed when a new token is needed.
  Function tokenGenerator;

  /// [autoReconnect] - Enable auto reconnect.
  bool autoReconnect;

  /// [logger] - Logger instance from the extended classes.
  Logger logger;
  late Signaling? signaling;
  PeerConnection webRTCPeer = PeerConnection();
  int? reconnectionInterval;
  bool? alreadyDisconnected;
  bool? firstReconnection;
  bool stopReconnection = false;
  bool isReconnecting = false;
  Map<String, dynamic>? options;

  BaseWebRTC({
    required this.streamName,
    required this.tokenGenerator,
    required this.autoReconnect,
    required this.logger,
    this.signaling,
    this.reconnectionInterval = baseInterval,
    this.alreadyDisconnected = false,
    this.firstReconnection = true,
    this.options,
  });

  /// Get current RTC peer connection.
  ///
  /// Returns the [RTCPeerConnection].
  Future<RTCPeerConnection> getRTCPeerConnection() async {
    return await webRTCPeer.getRTCPeer();
  }

  /// Stops connection.
  stop() {
    logger.i('Stopping');
    webRTCPeer.closeRTCPeer();
    signaling?.close();
    signaling = null;
    webRTCPeer = PeerConnection();
  }

  /// Get if the current connection is active.
  ///
  /// Returns true if connected, false if not.
  bool isActive() {
    String? rtcPeerState = webRTCPeer.getRTCPeerStatus();
    logger.i('Broadcast status: ${rtcPeerState.toString()}||not_established ');
    return (rtcPeerState == 'connected');
  }

  // This method should be overrided by publish or view
  connect({Map<String, dynamic> options = const {}}) async {}

  // This method should be overrided by publish or view
  replaceConnection() async {}

  /// Sets reconnection if autoReconnect is enabled.
  setReconnect() {
    signaling?.on('migrate', this, (ev, context) async {
      signaling?.isMigrating = true;
      await replaceConnection();
      signaling?.isMigrating = false;
    });
    if (autoReconnect) {
      signaling?.on(SignalingEvents.connectionError, this, (event, context) {
        if ((firstReconnection == null || alreadyDisconnected == false)) {
          firstReconnection = false;
          reconnect();
        }
      });

      webRTCPeer.on(webRTCEvents['connectionStateChange'], this,
          (event, context) {
        var state = event.eventData;
        if ((state == 'failed' ||
                (state == 'disconnected' && alreadyDisconnected!)) &&
            firstReconnection!) {
          firstReconnection = false;
          reconnect();
        } else if (state == 'disconnected') {
          alreadyDisconnected = true;
          Timer(const Duration(milliseconds: 1500), () => reconnect());
        } else {
          alreadyDisconnected = false;
        }
      });
    }
  }

  /// Reconnects to last broadcast.
  ///
  reconnect() async {
    try {
      if (stopReconnection) {
        return;
      }

      logger.i('Attempting to reconnect...');
      if (!isActive() && !isReconnecting) {
        stop();
        isReconnecting = true;
        if (options != null) {
          await connect(options: options!);
        } else {
          await connect();
        }
        alreadyDisconnected = false;
        reconnectionInterval = baseInterval;
        firstReconnection = true;
        isReconnecting = false;
      }
    } catch (error) {
      isReconnecting = false;
      reconnectionInterval = nextReconnectInterval(reconnectionInterval!);
      logger.e(
          '''Reconnection failed, retrying in ${reconnectionInterval}ms. Error was: $error''');

      ///  Emits with every reconnection attempt made when an active stream
      ///  stopped unexpectedly.
      ///
      ///  [timeout] - Next retry interval in milliseconds.
      ///  [error] - Error object with cause of failure.
      emit(
          'reconnect', this, {'timeout': reconnectionInterval, 'error': error});
      Timer(Duration(milliseconds: reconnectionInterval!), () => reconnect());
    }
  }
}

int nextReconnectInterval(int interval) {
  return interval < maxReconnectionInterval ? interval * 2 : interval;
}

set stopReconnection(bool value) {
  stopReconnection = value;
}
