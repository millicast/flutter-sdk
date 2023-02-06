import 'dart:io';

import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
import 'package:flutter/foundation.dart';

var _logger = getLogger('MillicastPublishUserMedia');

const connectOptions = {
  'bandwidth': 0,
  'disableVideo': false,
  'disableAudio': false,
};

const String sourceId = String.fromEnvironment('sourceId');

class MillicastPublishUserMedia extends Publish {
  MillicastMedia? mediaManager;
  List<String>? supportedCodecs;

  MillicastPublishUserMedia(options, tokenGenerator, autoReconnect)
      : super(
            streamName: options['streamName'],
            tokenGenerator: tokenGenerator,
            autoReconnect: autoReconnect) {
    mediaManager = MillicastMedia(options);
  }

  static build(options, tokenGenerator, autoReconnect) async {
    MillicastPublishUserMedia instance =
        MillicastPublishUserMedia(options, tokenGenerator, autoReconnect);

    await instance.getMediaStream();
    return instance;
  }

  getMediaStream() async {
    try {
      return await mediaManager?.getMedia();
    } catch (e) {
      rethrow;
    }
  }

  muteMedia(type, boo) {
    if (type == 'audio') {
      mediaManager?.muteAudio(boolean: boo);
    } else if (type == 'video') {
      mediaManager?.muteVideo(boolean: boo);
    }
  }

  migrate() {
    signaling?.emit('migrate');
  }

  @override
  connect({Map<String, dynamic> options = connectOptions}) async {
    if (mediaManager == null) {
      throw Exception('mediaManager not initialized correctly');
    }
    await super.connect(
      options: {...options, 'mediaStream': mediaManager?.mediaStream},
    );
  }

  hangUp(bool connected) async {
    if (connected) {
      _logger.w('Disconnecting');
      await stop();
    }
    return connected;
  }

  updateBandwidth(num bitrate) async {
    await webRTCPeer.updateBitrate(bitrate: bitrate);
  }

  close() async {
    await webRTCPeer.closeRTCPeer();
  }
}

class MillicastMedia {
  MediaStream? mediaStream;
  late Map<String, dynamic> constraints;
  MillicastMedia(Map<String, dynamic>? options) {
    constraints = {
      'audio': {
        'echoCancellation': true,
        'channelCount': {'ideal': 2},
      },
      'video': {
        'height': 1080,
        'width': 1920,
      },
    };

    if (options != null && options['constraints'] != null) {
      constraints.addAll(options['constraints']);
    }
  }

  getMedia() async {
    /// gets user cam and mic

    try {
      mediaStream = await navigator.mediaDevices.getUserMedia(constraints);

      // Adding this check check so we don't lose web support
      if (!kIsWeb) {
        if (Platform.isIOS) {
          mediaStream?.getAudioTracks()[0].enableSpeakerphone(true);
        }
      }
      return mediaStream;
    } catch (e) {
      throw Error();
    }
  }

  /// [boolean] - true if you want to mute the audio, false for mute it.
  /// Returns [bool] - returns true if it was changed, otherwise returns false.
  bool muteAudio({boolean = true}) {
    var changed = false;
    if (mediaStream != null) {
      mediaStream?.getAudioTracks()[0].enabled = !boolean;
      changed = true;
    } else {
      _logger.e('There is no media stream object.');
    }
    return changed;
  }

  bool switchCamera({boolean = true}) {
    var changed = false;
    if (mediaStream != null) {
      MediaStreamTrack? mediaStreamTrack = mediaStream?.getVideoTracks()[0];
      Helper.switchCamera(mediaStreamTrack!);
      changed = true;
    } else {
      _logger.e('There is no media stream object.');
    }
    return changed;
  }

  ///
  /// [bool] boolean - true if you want to mute the video, false for mute it.
  /// Returns [bool] - returns true if it was changed, otherwise returns false.
  ///
  bool muteVideo({boolean = true}) {
    var changed = false;
    if (mediaStream != null) {
      mediaStream?.getVideoTracks()[0].enabled = !boolean;
      changed = true;
    } else {
      _logger.e('There is no media stream object.');
    }
    return changed;
  }
}
