import 'package:example/viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

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
  late View _view;
  Map options = {};
  bool isVideoMuted = false;
  bool isAudioMuted = false;
  bool isConnected = true;

  PeerConnection? webRtcPeer;
  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
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

    _view.on('multicast', _view, ((ev, context) {
      if (ev.eventData == false) {
        _projectSourceId(null, 'audio');
        _projectSourceId(null, 'video');
      }
      setState(() {});
    }));
    setState(() {});
  }

  void initRenderers() async {
    await _localRenderer.initialize();
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
          const Text('Subscriber App',
              style: TextStyle(color: Colors.black, fontSize: 15))
        ]),
        leading: BackButton(
            color: Colors.black, onPressed: () => Navigator.of(context).pop()),
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
          )
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: isMultisourceEnabled
          ? SizedBox(
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                          icon: const Icon(Icons.arrow_drop_up),
                          iconEnabledColor: Colors.white,
                          hint: const Text('Video Source',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                          dropdownColor: Colors.purple,
                          items: sourceIds.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _projectSourceId(value, 'video');
                            });
                          },
                        )),
                      )),
                  FloatingActionButton(
                    child:
                        Icon((!isVideoMuted) ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        _stopVideo();
                      });
                    },
                  ),
                  FloatingActionButton(
                    child: Icon(
                        (isAudioMuted) ? Icons.volume_off : Icons.volume_up),
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
                          icon: const Icon(Icons.arrow_drop_up),
                          iconEnabledColor: Colors.white,
                          hint: const Text('Audio Source',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15)),
                          dropdownColor: Colors.purple,
                          items: sourceIds.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(color: Colors.white),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _projectSourceId(value, 'audio');
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
                    child:
                        Icon((!isVideoMuted) ? Icons.pause : Icons.play_arrow),
                    onPressed: () {
                      setState(() {
                        _stopVideo();
                      });
                    },
                  ),
                  FloatingActionButton(
                    child: Icon(
                        (isAudioMuted) ? Icons.volume_off : Icons.volume_up),
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

  Future<void> _projectSourceId(String? value, String type) async {
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
