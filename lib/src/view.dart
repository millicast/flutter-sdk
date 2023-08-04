import 'dart:async';

import 'package:millicast_flutter_sdk/src/peer_connection.dart';
import 'package:millicast_flutter_sdk/src/signaling.dart';
import 'package:millicast_flutter_sdk/src/utils/fetch_error.dart';
import 'package:millicast_flutter_sdk/src/utils/reemit.dart';

import 'director.dart';
import 'utils/base_web_rtc.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'logger.dart';

var _logger = getLogger('View');

const Map<String, dynamic> _connectOptions = {
  'disableVideo': false,
  'disableAudio': false,
  'peerConfig': null
};

/// [View] manages a webSocket connection to view a stream using Millicast.
///
/// [View] extends [BaseWebRTC] class.
/// Before you can view an active broadcast, you will need:
/// - A connection path that you can get from  [Director] module or from your
/// own implementation based on [Get a Connection Path](https://dash.millicast.com/docs.html?pg=how-to-broadcast-in-js#get-connection-paths-sect).
/// [streamName] - Millicast existing Stream Name where you want to connect.
/// [tokenGenerator] - Callback function executed when a new token is needed.
/// [mediaElement] - Target  media element to mount stream.
/// [autoReconnect] = true - Enable auto reconnect to stream.
class View extends BaseWebRTC {
  Function? stopReemitingWebRTCPeerInstanceEvents;

  Function? stopReemitingSignalingInstanceEvents;

  View(
      {required String streamName,
      required Function tokenGenerator,
      RTCVideoRenderer? mediaElement,
      bool autoReconnect = true})
      : super(
            streamName: streamName,
            tokenGenerator: tokenGenerator,
            autoReconnect: autoReconnect,
            logger: _logger) {
    if (mediaElement != null) {
      webRTCPeer.on(webRTCEvents['track'], this, (ev, context) {
        RTCTrackEvent track = ev.eventData as RTCTrackEvent;
        if (track.streams.isNotEmpty) {
          mediaElement.srcObject = track.streams[0];
        }
      });
    }
  }

  /// Connects to an active stream as subscriber.
  ///
  /// [Object] options - General subscriber options.
  /// options['dtx'] = false - True to modify SDP for supporting dtx in opus.
  ///  Otherwise False.
  /// options['absCaptureTime'] = false - True to modify SDP for
  /// supporting absolute capture time header extension. Otherwise False.
  /// options['disableVideo'] = false - Disable the opportunity to receive
  /// video stream.
  /// options['disableAudio'] = false - Disable the opportunity to receive
  /// audio stream.
  /// options['multiplexedAudioTracks'] - Number of audio tracks to recieve
  /// VAD multiplexed audio for secondary sources.
  /// options['pinnedSourceId'] - Id of the main source that will be received
  /// by the default MediaStream.
  /// options['excludedSourceIds'] - Do not receive media from the these
  /// source ids.
  /// options['events'] - Override which events will be delivered by the
  /// server (any of "active" | "inactive" | "vad" | "layers").*
  /// options['peerConfig']     - Options to configure the new
  /// RTCPeerConnection.
  /// options['layer'] - Select the simulcast encoding layer and svc layers
  /// for the main video track, leave empty for automatic layer selection
  /// based on bandwidth estimation.
  /// Returns Future object which resolves when the connection was
  /// successfully established.
  ///
  /// @example
  /// ```dart
  ///import 'package:flutter_webrtc/flutter_webrtc.dart';
  ///import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
  ///
  ///   ///Setting subscriber options
  /// DirectorSubscriberOptions directorSubscriberOptions =
  ///     DirectorSubscriberOptions(
  ///        streamAccountId: Constants.accountId,
  ///         streamName: Constants.streamName);

  /// /// Define callback for generate new token
  /// tokenGenerator() => Director.getSubscriber(directorSubscriberOptions);

  /// /// Create a new instance
  /// View view = View(
  ///     streamName: Constants.streamName,
  ///     tokenGenerator: tokenGenerator,
  ///     mediaElement: localRenderer);
  ///
  /// //Set track event handler to receive streams from Publisher.
  ///    view.webRTCPeer.on('track', this, (ev, context) {
  ///       _localRenderer.srcObject = ev.eventData as MediaStream?;
  // /  });

  /// /// Start connection to publisher
  /// try {
  ///   await view.connect();
  /// } catch (e) {
  ///   rethrow;
  /// }
  ///```
  @override
  connect({Map<String, dynamic> options = _connectOptions}) async {
    this.options = {..._connectOptions, ...options, 'setSDPToPeer': false};
    await initConnection({'migrate': false});
  }

  /// Select the simulcast encoding layer and svc layers for the main video
  /// track.
  ///
  /// [Map] layer - leave empty for automatic layer selection based on bandwidth
  /// estimation.

  select({Map? layer = const {}}) async {
    _logger.i('Viewer select layer values: $layer');
    await signaling?.cmd('select', {'layer': layer});
    _logger.i('Connected to streamName: $streamName');
  }

  /// Add remote receving track.
  ///
  /// String] media - Media kind ('audio' | 'video').
  /// [List<MediaStream>] streams - Streams the track will belong to.
  /// Return [Future<RTCRtpTransceiver>] Future that will be resolved when the
  /// RTCRtpTransceiver is assigned an mid value.
  ///
  /// Note: For Android, when adding both Audio & Video tracks, you must add
  /// Audio tracks first. If you add Video Tracks first,
  /// your transceiver will get disposed.
  ///
  /// @example
  /// ```dart
  /// import 'package:flutter_webrtc/flutter_webrtc.dart';
  /// import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
  ///
  /// // ... initialize connection and renderers using view object
  /// // ...
  /// MediaStream stream = await createLocalMediaStream('myStream');
  /// RTCRtpTransceiver transceiver1 = await view!
  ///     .addRemoteTrack(RTCRtpMediaType.RTCRtpMediaTypeAudio, [stream]);
  /// RTCRtpTransceiver transceiver = await view!
  ///     .addRemoteTrack(RTCRtpMediaType.RTCRtpMediaTypeVideo, [stream]);
  /// await view!.project('mySourceId', [
  ///   {'trackId': 'audio', 'mediaId': transceiver1.mid}
  /// ]);
  /// await view!.project('pip', [
  ///   {'trackId': 'video', 'mediaId': transceiver.mid}
  /// ]);
  ///
  /// stream.addTrack(transceiver1.receiver.track!);
  /// stream.addTrack(transceiver.receiver.track!);
  /// _localRenderer.srcObject = stream;
  /// // ...
  /// ```
  Future<RTCRtpTransceiver> addRemoteTrack(
      RTCRtpMediaType media, List<MediaStream> streams) async {
    _logger.i('Viewer adding remote  track $media');
    RTCRtpTransceiver transceiverLocal =
        await webRTCPeer.addRemoteTrack(media, streams);
    return transceiverLocal;
  }

  /// Start projecting source in selected media ids.
  ///
  /// [String] sourceId                       - Selected source id.
  /// [List<Map>] mapping                    - Mapping of the source track ids
  /// to the receiver mids
  /// [String] mapping.trackId                - Track id from the source
  /// (received on the "active" event), if not set the media kind will
  /// be used instead.
  /// [String] mapping.media                  - Track kind of the source
  /// ('audio' | 'video'), if not set the trackId will be used instead.
  /// [String] mapping.mediaId                 - mid value of the rtp receiver
  /// in which the media is going to be projected.
  /// [LayerInfo] mapping.layer                - Select the simulcast encoding
  /// layer and svc layers, only applicable to video tracks.
  ///

  project(String? sourceId, List<Map> mapping) async {
    for (var map in mapping) {
      if (map['trackId'] == null && map['media'] == null) {
        _logger
            .e('Error in projection mapping, trackId and mediaId must be set');
        throw Error();
      }
      if (map['mediaId'] == null) {
        _logger.e('Error in projection mapping, mediaId must be set');
        throw Error();
      }
      RTCPeerConnection? peer = await webRTCPeer.getRTCPeer();
      List<RTCRtpTransceiver> peerTransceiverList =
          await peer.getTransceivers();

      try {
        peerTransceiverList.firstWhere((t) => t.mid == map['mediaId']);
      } catch (e) {
        _logger.e('Error in projection mapping, ${map['mediaId']}'
            'mid not found in local transceivers');
      }
    }
    _logger.i('Viewer project source:$sourceId layer mappings: $mapping');
    Map<String, dynamic> data = {'sourceId': sourceId, 'mapping': mapping};
    await signaling?.cmd('project', data);
    logger.i('Projection done');
  }

  /// Stop projecting attached source in selected media ids.
  ///
  ///  [List<String>] mediaIds - mid value of the receivers that are going to
  /// be detached.
  ///

  unproject(List<String> mediaIds) async {
    _logger.d('Viewer unproject mediaIds: $mediaIds');
    await signaling?.cmd('unproject', {mediaIds});
    _logger.i('Unprojection done');
  }

  @override
  replaceConnection() async {
    logger.i('Migrating current connection');
    await initConnection({'migrate': true});
  }

  initConnection(Map<String, dynamic> data) async {
    _logger.d('Viewer connect options values: $options');

    if (isActive() && !data['migrate']) {
      _logger.w('Viewer currently subscribed');
      throw Error();
    }
    MillicastDirectorResponse subscriberData;
    try {
      subscriberData = await tokenGenerator();
    } on FetchException catch (error) {
      _logger.e('Error generating token.');
      if(error.status == 401) {
        // should not reconnect
        this.stopReconnection = true;
      } else {
        // should reconnect with exponential back off
        reconnect();
      }
      rethrow;
    } catch (error) {
      rethrow;
    }
    // ignore: unnecessary_null_comparison
    if (subscriberData == null) {
      _logger.e('Error while subscribing. Subscriber data required');
    }
    var signalingInstance = Signaling({
      'streamName': streamName,
      'url': '${subscriberData.urls[0]}?token=${subscriberData.jwt}'
    });

    var webRTCPeerInstance = data['migrate'] ? PeerConnection() : webRTCPeer;
    await webRTCPeerInstance.createRTCPeer(options?['peerConfig']);

    // Stop emiting events from the previous instances
    if (stopReemitingWebRTCPeerInstanceEvents != null) {
      stopReemitingWebRTCPeerInstanceEvents!();
    }
    if (stopReemitingSignalingInstanceEvents != null) {
      stopReemitingSignalingInstanceEvents!();
    }

    stopReemitingWebRTCPeerInstanceEvents = reemit(webRTCPeerInstance, this,
        [webRTCEvents['track'], webRTCEvents['connectionStateChange']]);

    stopReemitingSignalingInstanceEvents =
        reemit(signalingInstance, this, [SignalingEvents.broadcastEvent]);

    Future getLocalSDPFuture = webRTCPeerInstance
        .getRTCLocalSDP(options: {...options!, 'stereo': true});
    Future signalingConnectFuture = signalingInstance.connect();

    Iterable<Future<dynamic>> iterFuture = [
      getLocalSDPFuture,
      signalingConnectFuture
    ];
    var resolvedFutures = await Future.wait(iterFuture);
    String localSdp = resolvedFutures[0];

    Future subscribeFuture =
        signalingInstance.subscribe(localSdp, options: options);
    Future<void>? setLocalDescriptionFuture = webRTCPeerInstance.peer
        ?.setLocalDescription(webRTCPeerInstance.sessionDescription!);
    iterFuture = [subscribeFuture, setLocalDescriptionFuture!];

    resolvedFutures = await Future.wait(iterFuture);
    String remoteSdp = resolvedFutures[0];

    await webRTCPeerInstance.setRTCRemoteSDP(remoteSdp);
    _logger.i('Connected to streamName: $streamName');
    Signaling? oldSignlaling = signaling;
    PeerConnection? oldWebRTCPeer = webRTCPeer;
    signaling = signalingInstance;
    webRTCPeer = webRTCPeerInstance;

    emit(SignalingEvents.connectionSuccess, this);

    setReconnect();

    if (data['migrate']) {
      webRTCPeer.on(webRTCEvents['connectionStateChange'], webRTCPeer,
          (ev, context) async {
        if (ev.eventData ==
            RTCIceConnectionState.RTCIceConnectionStateConnected) {
          Timer(const Duration(milliseconds: 1000), () {
            oldSignlaling?.close();
            oldWebRTCPeer?.closeRTCPeer();
            oldSignlaling = null;
            oldWebRTCPeer = null;
            _logger.i('Current connection migrated');
          });
        } else if ([
          RTCIceConnectionState.RTCIceConnectionStateClosed,
          RTCIceConnectionState.RTCIceConnectionStateFailed,
          RTCIceConnectionState.RTCIceConnectionStateDisconnected
        ].contains(ev.eventData)) {
          oldSignlaling?.close();
          oldWebRTCPeer?.closeRTCPeer();
          oldSignlaling = null;
          oldWebRTCPeer = null;
        }
      });
    }
  }
}
