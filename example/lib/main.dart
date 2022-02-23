import 'package:example/publisher.dart';
import 'package:example/utils/constants.dart';
import 'package:example/viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';
import 'package:share/share.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';
import 'package:settings_ui/settings_ui.dart';

import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

import 'millicast_publisher_user_media.dart';

const type = String.fromEnvironment('type');
bool isVideoMuted = false;
bool isAudioMuted = false;
bool isConnected = true;
String? dropdownvalue = 'Default';

void main() async {
  Logger.level = Level.info;
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: const MyHomePage(title: 'Millicast SDK Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late String _viewers = '0';
  late bool _publisher;
  late MillicastPublishUserMedia _publisherMedia;
  late View _view;
  Map options = {};

  PeerConnection? webRtcPeer;
  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initRenderers();
    switch (type) {
      case 'subscribe':
        _publisher = false;
        subscribeExample();
        break;
      case 'publish':
        _publisher = true;
        publishExample(options);

        break;
      default:
    }
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
    StreamEvents events = await StreamEvents.init();
    events.onUserCount(onUserCountOptions);
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

  _updateBitrate(num bitrate) async {
    _publisherMedia.updateBandwidth(bitrate);
  }

  void subscribeExample() async {
    _view = await viewConnect(_localRenderer);

    _view.on('simulcast', _view, ((ev, context) {
      if (ev.eventData == true) {
        _proyectSourceId(null, 'audio');
        _proyectSourceId(null, 'video');
      }
      setState(() {});
    }));
    setState(() {});
  }

  void initRenderers() async {
    await _localRenderer.initialize();
  }

  void openAppSettings(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute(
        fullscreenDialog: true,
        builder: (context) => Scaffold(
              appBar: AppBar(
                foregroundColor: Colors.black,
                title: const Text(
                  'Settings',
                  style: TextStyle(color: Colors.black),
                ),
                backgroundColor: Colors.white,
              ),
              body: SettingsList(
                sections: [
                  SettingsSection(
                    title: const Text('Choose your configuration'),
                    tiles: <SettingsTile>[
                      SettingsTile.navigation(
                        leading: const Icon(Icons.title),
                        title: const Text('SourceId'),
                        value: SizedBox(
                            child: TextField(
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Enter a stream SourceId',
                                ),
                                onSubmitted: (sourceId) {
                                  options['sourceId'] = sourceId;
                                  TextInputAction.next;
                                })),
                      ),
                      SettingsTile.navigation(
                        leading: const Icon(Icons.speed),
                        title: const Text('BitRate'),
                        value: SizedBox(
                            child: TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Enter bitrate limit in Kbps',
                          ),
                          onSubmitted: (bitrate) {
                            _updateBitrate(num.parse(bitrate));
                          },
                        )),
                      ),
                      SettingsTile.switchTile(
                        onToggle: (value) {
                          // Enable Simulcast
                        },
                        initialValue: false,
                        leading: const Icon(Icons.splitscreen_sharp),
                        title: const Text('Simulcast'),
                      ),
                      SettingsTile.switchTile(
                        onToggle: (value) {
                          // Enable Echo Cancellation
                        },
                        initialValue: false,
                        leading: const Icon(Icons.music_off),
                        title: const Text('Echo Cancellation'),
                      ),
                      SettingsTile.switchTile(
                        onToggle: (value) {
                          // Adio mono stereo
                        },
                        initialValue: false,
                        leading: const Icon(Icons.headset),
                        title: const Text('Audio'),
                        description: const Text('Mono or Stereo Audio'),
                      ),
                    ],
                  ),
                ],
              ),
            )));
  }

  @override
  Widget build(BuildContext context) {
    String? selectedSource;
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
          Text(widget.title,
              style: const TextStyle(color: Colors.black, fontSize: 15))
        ]),
        actions: _publisher
            ? <Widget>[
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
                    style: ElevatedButton.styleFrom(
                        primary: Colors.white, elevation: 0),
                    child: const Icon(
                      Icons.settings,
                      color: Colors.black,
                      size: 30,
                    ),
                    onPressed: () {
                      openAppSettings(context);
                    }),
                Container(
                  width: 25,
                ),
              ]
            : null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _publisher
          ? SizedBox(
              width: 450.0,
              child:
                  Column(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 4),
                                              child: Text(
                                                value.toString(),
                                                style: const TextStyle(
                                                    fontSize: 30,
                                                    color: Colors.white,
                                                    fontFamily: 'Helvetica',
                                                    fontWeight:
                                                        FontWeight.bold),
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
                                  color:
                                      isConnected ? Colors.red : Colors.white,
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
                                'View my stream at https://viewer.millicast.com/?streamId=${Constants.accountId}/${Constants.streamName}',
                                subject: 'Look what I made!',
                              );
                            },
                          ),
                        ],
                      ),
                    ])
              ]))
          : isMultisourceEnabled
              ? SizedBox(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.only(
                            left: 1,
                          ),
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              icon: Icon(Icons.arrow_drop_up),
                              iconEnabledColor: Colors.white,
                              hint: const Text('Video Source',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15)),
                              dropdownColor: Colors.purple,
                              items: sourceIds.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _proyectSourceId(value, 'video');
                                });
                              },
                            )),
                          )),
                      FloatingActionButton(
                        child: Icon(
                            (!isVideoMuted) ? Icons.pause : Icons.play_arrow),
                        onPressed: () {
                          setState(() {
                            _stopVideo();
                          });
                        },
                      ),
                      FloatingActionButton(
                        child: Icon((isAudioMuted)
                            ? Icons.volume_off
                            : Icons.volume_up),
                        onPressed: () {
                          setState(() {
                            _stopAudio();
                          });
                        },
                      ),
                      Container(
                          decoration: BoxDecoration(
                              color: Colors.purple,
                              borderRadius: BorderRadius.circular(15)),
                          padding: const EdgeInsets.only(
                            left: 1,
                          ),
                          child: ButtonTheme(
                            alignedDropdown: true,
                            child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                              icon: Icon(Icons.arrow_drop_up),
                              iconEnabledColor: Colors.white,
                              hint: const Text('Audio Source',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 15)),
                              dropdownColor: Colors.purple,
                              items: sourceIds.map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(
                                    value,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _proyectSourceId(value, 'audio');
                                });
                              },
                            )),
                          ))
                    ]))
              : SizedBox(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FloatingActionButton(
                        child: Icon(
                            (!isVideoMuted) ? Icons.pause : Icons.play_arrow),
                        onPressed: () {
                          setState(() {
                            _stopVideo();
                          });
                        },
                      ),
                      FloatingActionButton(
                        child: Icon((isAudioMuted)
                            ? Icons.volume_off
                            : Icons.volume_up),
                        onPressed: () {
                          setState(() {
                            _stopAudio();
                          });
                        },
                      )
                    ],
                  ),
                ),
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

  Future<void> _proyectSourceId(String? value, String type) async {
    await _view.project(value, [
      {'trackId': type, 'mediaId': type == 'video' ? '0' : '1'},
    ]);
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
