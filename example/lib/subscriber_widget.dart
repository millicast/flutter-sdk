import 'dart:async';
import 'dart:convert';

import 'package:example/viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
import 'package:millicast_flutter_sdk/src/view.dart' as millicast_view;

import 'subscriber_settings_widget.dart';

class SubscriberWidget extends StatefulWidget {
  const SubscriberWidget({Key? key}) : super(key: key);
  @override
  SubscriberWidgetState createState() => SubscriberWidgetState();
}

class SubscriberWidgetState extends State<SubscriberWidget> {
  final stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late String _viewers = '0';
  millicast_view.View? _view;
  Map options = {};
  bool isVideoMuted = false;
  bool isAudioMuted = false;

  /// Web socket should be closing
  bool isDeactivating = false;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void activate() async {
    await _view!.webRTCPeer.closeRTCPeer();
    super.activate();
  }

  @override
  void deactivate() async {
    isConnectedSubsc = false;
    isDeactivating = true;
    _view!.stopReconnection = true;

    await closeCameraStream();
    await _view?.stop();
    super.deactivate();
  }

  void callBuildSubscriber() async {
    _view = await buildSubscriber(_localRenderer);

    subscribeExample();
  }

  @override
  void initState() {
    initRenderers();
    callBuildSubscriber();
    super.initState();
  }

  void refresh(countChange) {
    setState(() {
      _viewers = countChange.toString();
    });
  }

  void subscribeExample() async {
    _view?.on(SignalingEvents.connectionSuccess, _view, (ev, context) async {
      if (isDeactivating) {
        isConnectedSubsc = false;
        await _view?.stop();
      }
    });
    await viewConnect(_view!);
    _view?.on('multisource', _view, ((ev, context) {
      if (ev.eventData == false) {
        _projectSourceId(null, 'audio');
        _projectSourceId(null, 'video');
      }

      setState(() {});
    }));

    _view?.on('layerChange', _view, ((ev, context) {
      simulcastQualityValue = 'Auto';
      _view?.select();
      setState(() {});
    }));

    setUserCount();

    setState(() {});
  }

  void setUserCount() {
    // Add listener of broacastEvent to get UserCount
    _view!.on('broadcastEvent', this, setUserCountHandler);
  }

  void setUserCountHandler(event, context) {
    var data = jsonEncode(event.eventData);
    Map<String, dynamic> dataMap = jsonDecode(data);
    if (dataMap['name'] == 'viewercount') {
      refresh(dataMap['data']['viewercount']);
    }
  }

  void initRenderers() async {
    await _localRenderer.initialize();
  }

  Future<void> closeCameraStream() async {
    if (_localRenderer.srcObject != null) {
      _localRenderer.srcObject?.getTracks().forEach((element) async {
        await element.stop();
      });
      await _localRenderer.srcObject?.dispose();
      _localRenderer.srcObject = null;
    }
  }

  void handleClose() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  String calculateTime(int seconds) {
    var hoursStr =
        ((seconds / (60 * 60)) % 60).floor().toString().padLeft(2, '0');
    var minutesStr = ((seconds / 60) % 60).floor().toString().padLeft(2, '0');
    var secondsStr = (seconds % 60).floor().toString().padLeft(2, '0');
    return '$hoursStr:$minutesStr:$secondsStr';
  }

  refreshStream() async {
    await _view!.webRTCPeer.closeRTCPeer();
    callBuildSubscriber();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our AppBar title.
        title: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              Image.asset(
                'assets/millicastImage.png',
                fit: BoxFit.contain,
                height: 30,
              ),
              const Text('Subscriber App',
                  style: TextStyle(color: Colors.black, fontSize: 15))
            ]),
        leading: Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: BackButton(
                color: Colors.black, onPressed: () => handleClose())),

        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(
                top: 20.0,
              ),
              child: Text(_viewers,
                  style: const TextStyle(
                    color: Colors.black,
                  ))),
          const IconTheme(
            data: IconThemeData(color: Colors.black, size: 30),
            child: Icon(
              Icons.remove_red_eye_outlined,
              size: 20,
            ),
          ),
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                alignment: const Alignment(0, 0),
                backgroundColor: Colors.white,
                elevation: 0,
              ),
              child: const Icon(
                Icons.settings,
                color: Colors.black,
                size: 25,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          SubscriberSettingsWidget(
                              view: _view, options: options),
                    ));
              }),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
          child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
            FloatingActionButton(
              heroTag: const Text('Stop Video'),
              child: Icon((!isVideoMuted) ? Icons.pause : Icons.play_arrow),
              onPressed: () {
                setState(() {
                  _stopVideo();
                });
              },
            ),
            FloatingActionButton(
              heroTag: const Text('Stop Audio'),
              child: Icon((isAudioMuted) ? Icons.volume_off : Icons.volume_up),
              onPressed: () {
                setState(() {
                  _stopAudio();
                });
              },
            ),
          ])),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Stack(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(color: Colors.black54),
                child: RTCVideoView(_localRenderer),
              ),
              Positioned(
                  top: 40,
                  left: 20,
                  height: 45,
                  width: isConnectedSubsc ? 50 : 85,
                  child: FloatingActionButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    backgroundColor:
                        isConnectedSubsc ? Colors.red : Colors.grey,
                    heroTag: 1,
                    onPressed: null,
                    child: isConnectedSubsc
                        ? const Text('LIVE')
                        : const Text('NOT LIVE'),
                  ))
            ],
          );
        },
      ),
    );
  }

  Future<void> _projectSourceId(String? value, String type) async {
    await _view?.project(value, [
      {'trackId': type, 'mediaId': type == 'video' ? '0' : '1'},
    ]);

    isSimulcastEnabled = false;
  }

  void _stopVideo() {
    MediaStream? stream = _localRenderer.srcObject;

    if (isAudioMuted == true) {
      stream?.getVideoTracks()[0].enabled = isVideoMuted;
    } else {
      stream?.getAudioTracks()[0].enabled = isVideoMuted;
      stream?.getVideoTracks()[0].enabled = isVideoMuted;
    }
    isVideoMuted = !isVideoMuted;
  }

  void _stopAudio() {
    MediaStream? stream = _localRenderer.srcObject;
    stream?.getAudioTracks()[0].enabled = isAudioMuted;
    isAudioMuted = !isAudioMuted;
  }
}
