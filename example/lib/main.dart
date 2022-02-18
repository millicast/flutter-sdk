import 'package:example/publisher.dart';
import 'package:example/utils/constants.dart';
import 'package:example/viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:logger/logger.dart';

import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

import 'millicast_publisher_user_media.dart';

const type = String.fromEnvironment('type');

bool isVideoMuted = false;
bool isAudioMuted = false;
bool isConnected = true;
String? dropdownvalue = 'Default';

void main() async {
  Logger.level = Level.debug;
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
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  late String _viewers = '0';
  late bool _publisher;
  late MillicastPublishUserMedia _publisherMedia;

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
        publishExample();

        break;
      default:
    }
    super.initState();
  }

  void publishExample() async {
    _publisherMedia = await publishConnect(_localRenderer);
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
    } else {
      _publisherMedia = await publishConnect(_localRenderer);
    }
  }

  _updateBitrate(num bitrate) async {
    _publisherMedia.updateBandwidth(bitrate);
  }

  void subscribeExample() async {
    await viewConnect(_localRenderer);
    setState(() {});
  }

  void initRenderers() async {
    await _localRenderer.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.white,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Row(children: [
          Image.asset(
            'assets/millicastImage.png',
            fit: BoxFit.contain,
            height: 30,
          ),
          Text(widget.title,
              style: const TextStyle(color: Colors.black, fontSize: 15))
        ]),
        actions: _publisher
            ? <Widget>[
                DropdownButtonHideUnderline(
                    child: DropdownButton(
                  items: [
                    '100',
                    '250',
                    '1000',
                    'Custom',
                    'Default',
                  ].map((String items) {
                    return DropdownMenuItem(
                      value: items,
                      child: Text('$items Kbps'),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownvalue = newValue!;
                      _updateBitrate(int.parse(dropdownvalue!));
                    });
                  },
                  onTap: () {},
                  icon: const Icon(Icons.settings),
                )),
                Padding(
                    padding: const EdgeInsets.only(top: 20.0, right: 5.0),
                    child: Text(_viewers,
                        style: const TextStyle(color: Colors.black))),
                const IconTheme(
                  data: IconThemeData(color: Colors.black),
                  child: Icon(Icons.remove_red_eye_outlined),
                ),
              ]
            : null,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _publisher
          ? SizedBox(
              width: 250.0,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    FloatingActionButton(
                      child: const Icon(Icons.switch_camera),
                      onPressed: () {
                        setState(() {
                          _switchCamera();
                        });
                      },
                    ),
                    FloatingActionButton(
                      tooltip: 'Hangup',
                      child: Icon(
                          (isVideoMuted) ? Icons.videocam_off : Icons.videocam),
                      onPressed: () {
                        setState(() {
                          _muteVideo();
                        });
                      },
                    ),
                    FloatingActionButton(
                      child: Icon(
                          (isAudioMuted) ? Icons.mic_off : Icons.mic_outlined),
                      onPressed: () {
                        setState(() {
                          _muteAudio();
                        });
                      },
                    ),
                    FloatingActionButton(
                      child: Icon(
                          (isConnected)
                              ? Icons.stop_circle_outlined
                              : Icons.play_circle_filled_outlined,
                          color: isConnected ? Colors.red : Colors.white),
                      onPressed: () {
                        setState(() {
                          _hangUp(isConnected);
                        });
                      },
                    ),
                  ]))
          : null,
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
