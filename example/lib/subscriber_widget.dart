import 'package:example/utils/constants.dart';
import 'package:example/viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'subscriber_settings_widget.dart';

import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

Logger _logger = getLogger('SubscriberWidget');

class SubscriberWidget extends StatefulWidget {
  const SubscriberWidget({Key? key}) : super(key: key);
  @override
  _SubscriberWidgetState createState() => _SubscriberWidgetState();
}

class _SubscriberWidgetState extends State<SubscriberWidget> {
  final stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late String _viewers = '0';
  View? _view;
  Map options = {};
  bool isVideoMuted = false;
  bool isAudioMuted = false;
  bool isConnected = true;
  StreamEvents? events;

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
  void deactivate() async {
    if (events != null) {
      events?.stop();
    }
    if (_localRenderer != null) {
      await closeCameraStream();
    }
    if (_view != null) {
      if (_view?.webRTCPeer != null) {
        await _view?.webRTCPeer.closeRTCPeer();
      }
    }
    super.deactivate();
  }

  @override
  void initState() {
    initRenderers();
    subscribeExample();
    super.initState();
  }

  void refresh(countChange) {
    setState(() {
      _viewers = countChange.toString();
    });
  }

  void subscribeExample() async {
    _view = await viewConnect(_localRenderer);

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
    setState(() {});

    Map<String, dynamic> onUserCountOptions = {
      'accountId': Constants.accountId,
      'streamName': Constants.streamName,
      'callback': (countChange) => {refresh(countChange)},
    };

    /// Add UserCount event listener
    StreamEvents events = await StreamEvents.init();
    events.onUserCount(onUserCountOptions);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
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
                primary: Colors.white,
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
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                  alignment: const Alignment(0, 0),
                  primary: Colors.white,
                  elevation: 0),
              child: const Icon(
                Icons.replay_outlined,
                color: Colors.black,
                size: 25,
              ),
              onPressed: () async {
                await _view?.webRTCPeer.closeRTCPeer();
                subscribeExample();
                setState(() {
                  isVideoMuted = false;
                  isAudioMuted = false;
                  isConnected = true;
                });
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
          return Center(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RTCVideoView(_localRenderer),
              decoration: const BoxDecoration(color: Colors.black54),
            ),
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
