import 'dart:io';

import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'dart:convert';

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

class _PublisherWidgetState extends State<PublisherWidget>
    with WidgetsBindingObserver {
  Map options = {};

  _PublisherWidgetState();

  final stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late String _viewers = '0';
  late MillicastPublishUserMedia _publisherMedia;
  bool isVideoMuted = false;
  bool isConnected = false;
  bool isLoading = false;
  bool isAudioMuted = false;
  bool _isMirrored = true;

  PeerConnection? webRtcPeer;
  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }

  @override
  void deactivate() async {
    if (_localRenderer.srcObject != null) {
      await closeCameraStream();
    }
    if (_publisherMedia != null) {
      setState(() {
        _hangUp(true);
        isAudioMuted = false;
        isVideoMuted = false;
        isConnected = false;
      });
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
    initPublish();
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    switch (state) {
      case AppLifecycleState.resumed:
        _publisherMedia = await buildPublisher(_localRenderer);
        setState(() {
          isAudioMuted = false;
          isVideoMuted = false;
          isConnected = false;
        });
        _logger.i('Resumed');
        break;
      case AppLifecycleState.inactive:
        await _hangUp(true);
        _logger.i('Inactive');
        break;
      case AppLifecycleState.paused:
        _logger.i('Paused');
        break;
      case AppLifecycleState.detached:
        _logger.i('Detached');
        break;
    }
  }

  Future publish(Map options) async {
    _publisherMedia = await connectPublisher(_publisherMedia, options);
    setState(() {
      stopWatchTimer.onExecute.add(StopWatchExecute.start);
    });

    Map<String, dynamic> onUserCountOptions = {
      'accountId': Constants.accountId,
      'streamName': Constants.streamName,
      'callback': (countChange) => {refresh(countChange)},
    };

    setUserCount();
  }

  void initPublish() async {
    _publisherMedia = await buildPublisher(_localRenderer);
    setState(() {
      if (Platform.isIOS) {
        _isMirrored = false;
      }
    });
  }

  void setUserCount() {
    // Add listener of broacastEvent to get UserCount
    _publisherMedia.on('broadcastEvent', this, (event, context) {
      var data = jsonEncode(event.eventData);
      Map<String, dynamic> dataMap = jsonDecode(data);
      if (dataMap['name'] == 'viewercount') {
        refresh(dataMap['data']['viewercount']);
      }
    });
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
    _isMirrored = !_isMirrored;
  }

  Future _hangUp([bool? _isConnected]) async {
    _isConnected ??= isConnected;
    if (_isConnected) {
      setState(() {
        _viewers = '0';
        isConnected = false;
      });
      await _publisherMedia.hangUp(_isConnected);
      stopWatchTimer.onExecute.add(StopWatchExecute.stop);
    } else {
      setState(() {
        isConnected = true;
      });
      stopWatchTimer.onExecute.add(StopWatchExecute.reset);
      await publish(options);
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
            height: 30,
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
                              options: options,
                              isConnected: isConnected),
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
                            tooltip: 'HangUp',
                            child: (isLoading)
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : (isConnected)
                                    ? Icon(Icons.stop,
                                        color: isConnected
                                            ? Colors.red
                                            : Colors.white,
                                        size: 50)
                                    : Icon(
                                        Icons.play_circle_filled_outlined,
                                        color: isConnected
                                            ? Colors.red
                                            : Colors.white,
                                        size: 50,
                                      ),
                            onPressed: () async {
                              if (isLoading) {
                                return;
                              }
                              setState(() {
                                isLoading = true;
                              });
                              await _hangUp();
                              setState(() {
                                isLoading = false;
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
              child: RTCVideoView(_localRenderer, mirror: _isMirrored),
              decoration: const BoxDecoration(color: Colors.black54),
            ),
          );
        },
      ),
    );
  }
}
