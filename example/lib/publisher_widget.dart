import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'millicast_publisher_user_media.dart';

import 'package:example/publisher.dart';
import 'package:example/utils/constants.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:share_plus/share_plus.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'publisher_settings_widget.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

Logger _logger = getLogger('main');

class PublisherWidget extends StatefulWidget {
  const PublisherWidget({Key? key}) : super(key: key);
  @override
  _PublisherWidgetState createState() => _PublisherWidgetState();
}

class _PublisherWidgetState extends State<PublisherWidget> {
  Map options = {};

  _PublisherWidgetState();

  final stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late String _viewers = '0';
  late MillicastPublishUserMedia _publisherMedia;
  bool isVideoMuted = false;
  bool isAudioMuted = false;
  bool isConnected = true;
  StreamEvents? events;

  PeerConnection? webRtcPeer;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() async {
    if (events != null) {
      events?.stop();
    }
    if (_localRenderer != null) {
      await closeCameraStream();
    }
    if (_publisherMedia != null) {
      if (_publisherMedia.webRTCPeer != null) {
        await _publisherMedia.webRTCPeer.closeRTCPeer();
      }
    }
    super.deactivate();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void initState() {
    initRenderers();
    publishExample(options);
    super.initState();
  }

  void publishExample(Map options) async {
    _publisherMedia = await publishConnect(_localRenderer, options);
    setState(() {
      stopWatchTimer.onExecute.add(StopWatchExecute.start);
    });

    Map<String, dynamic> onUserCountOptions = {
      'accountId': Constants.accountId,
      'streamName': Constants.streamName,
      'callback': (countChange) => {refresh(countChange)},
    };

    /// Add UserCount event listener
    events = await StreamEvents.init();
    events?.onUserCount(onUserCountOptions);
  }

  void refresh(countChange) {
    setState(() {
      _viewers = countChange.toString();
    });
  }

  _muteVideo() {
    _publisherMedia.muteMedia('video', !isVideoMuted);
    isVideoMuted = !isVideoMuted;
  }

  _muteAudio() {
    _publisherMedia.muteMedia('audio', !isAudioMuted);
    isAudioMuted = !isAudioMuted;
  }

  _switchCamera() {
    _publisherMedia.mediaManager?.switchCamera();
  }

  _hangUp(bool _isConnected) async {
    _isConnected = isConnected;
    setState(() {
      isConnected = !isConnected;
    });
    if (_isConnected) {
      _publisherMedia.hangUp(_isConnected);
      stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    } else {
      _publisherMedia = await publishConnect(_localRenderer, options);
      stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      stopWatchTimer.onExecute.add(StopWatchExecute.start);
    }
  }

  void initRenderers() async {
    await _localRenderer.initialize();
  }

  void handleClose() {
    Navigator.of(context).pushReplacementNamed('/');
  }

  Future<void> closeCameraStream() async {
    if (_localRenderer.srcObject != null) {
      _localRenderer.srcObject?.getTracks().forEach((element) async {
        await element.stop();
      });
      await _localRenderer.srcObject?.dispose();
      _localRenderer.srcObject = null;
    }
    await _localRenderer.dispose();
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
        title: Row(mainAxisSize: MainAxisSize.max, children: [
          Image.asset(
            'assets/millicastImage.png',
            fit: BoxFit.contain,
            height: 40,
          ),
          Container(
            width: 5,
          ),
          const Text('Publisher App',
              style: TextStyle(color: Colors.black, fontSize: 15))
        ]),
        leading:
            BackButton(color: Colors.black, onPressed: () => handleClose()),
        actions: <Widget>[
          Padding(
              padding: const EdgeInsets.only(top: 20.0, right: 5.0),
              child: Text(_viewers,
                  style: const TextStyle(
                    color: Colors.black,
                  ))),
          const IconTheme(
            data: IconThemeData(color: Colors.black, size: 30),
            child: Icon(
              Icons.remove_red_eye_outlined,
              size: 30,
            ),
          ),
          ElevatedButton(
              style:
                  ElevatedButton.styleFrom(primary: Colors.white, elevation: 0),
              child: const Icon(
                Icons.settings,
                color: Colors.black,
                size: 30,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (BuildContext context) =>
                          PublisherSettingsWidget(
                              publisherMedia: _publisherMedia,
                              options: options),
                    ));
              }),
          Container(
            width: 25,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: SizedBox(
          width: 450.0,
          child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: 'SwitchCamera',
                        child: const Icon(Icons.switch_camera),
                        onPressed: () {
                          setState(() {
                            _switchCamera();
                          });
                        },
                      ),
                      Container(
                        width: 5,
                      ),
                      FloatingActionButton(
                        heroTag: 'MuteAudio',
                        child: Icon((isAudioMuted)
                            ? Icons.mic_off
                            : Icons.mic_outlined),
                        onPressed: () {
                          setState(() {
                            _muteAudio();
                          });
                        },
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 50.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        StreamBuilder<int>(
                          stream: stopWatchTimer.secondTime,
                          initialData: 0,
                          builder: (context, snap) {
                            final value = snap.data;
                            return Column(
                              children: <Widget>[
                                Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: <Widget>[
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 4),
                                          child: Text(
                                            calculateTime(value!),
                                            style: const TextStyle(
                                                fontSize: 30,
                                                color: Colors.white,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    )),
                              ],
                            );
                          },
                        ),
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: FloatingActionButton(
                            heroTag: 'HangUp',
                            tooltip: 'Hangup',
                            child: Icon(
                              (isConnected)
                                  ? Icons.stop_outlined
                                  : Icons.play_circle_filled_outlined,
                              color: isConnected ? Colors.red : Colors.white,
                              size: 50,
                            ),
                            onPressed: () {
                              setState(() {
                                _hangUp(isConnected);
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      FloatingActionButton(
                        heroTag: 'MuteVideo',
                        tooltip: 'MuteVideo',
                        child: Icon((isVideoMuted)
                            ? Icons.videocam_off
                            : Icons.videocam),
                        onPressed: () {
                          setState(() {
                            _muteVideo();
                          });
                        },
                      ),
                      Container(
                        width: 5,
                      ),
                      FloatingActionButton(
                        heroTag: 'Share',
                        child: const Icon(Icons.share),
                        onPressed: () {
                          Share.share(
                            '''View my stream at https://viewer.millicast.com/?streamId=${Constants.accountId}/${Constants.streamName}, My accountId is: ${Constants.accountId}, My streamName is: ${Constants.streamName}, Jump in!''',
                            subject: 'Look what I made!',
                          );
                        },
                      ),
                    ],
                  ),
                ])
          ])),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Container(
              margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: RTCVideoView(_localRenderer, mirror: true),
              decoration: const BoxDecoration(color: Colors.black54),
            ),
          );
        },
      ),
    );
  }
}
