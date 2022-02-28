import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

import 'millicast_publisher_user_media.dart';

class SettingsWidget extends StatefulWidget {
  final MillicastPublishUserMedia? publisherMedia;
  final Map? options;
  const SettingsWidget({this.publisherMedia, this.options, Key? key})
      : super(key: key);
  @override
  _SettingsWidgetState createState() =>
      // ignore: no_logic_in_create_state
      _SettingsWidgetState(publisherMedia: publisherMedia, options: options);
}

class _SettingsWidgetState extends State<SettingsWidget> {
  int _bitrate = 0;
  bool _audio = false;
  bool _simulcast = false;
  Map? options;
  final _formKey = GlobalKey<FormState>();
  MillicastPublishUserMedia? publisherMedia;

  _SettingsWidgetState({required this.publisherMedia, required this.options});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            title: 'Choose your configuration',
            tiles: <SettingsTile>[
              SettingsTile(
                leading: const Icon(Icons.title),
                title: 'SourceId',
                onPressed: (BuildContext context) {
                  popupDialog(
                      context: context,
                      formKey: _formKey,
                      isTextbox: true,
                      handler: (value) {
                        options?['sourceId'] = value;
                      });
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.speed),
                title: 'BitRate',
                onPressed: (BuildContext context) {
                  popupDialog(
                      context: context,
                      formKey: _formKey,
                      isTextbox: true,
                      handler: (value) {
                        _bitrate = value != null ? int.parse(value) : 0;
                        _updateBitrate(_bitrate);
                      });
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.splitscreen_sharp),
                title: 'Codec',
                onPressed: (BuildContext context) {
                  popupDialog(
                      context: context,
                      formKey: _formKey,
                      isTextbox: false,
                      isDropdown: true,
                      handler: (value) {});
                },
              ),
              SettingsTile.switchTile(
                onToggle: (bool value) {
                  setState(() {
                    _simulcast = !_simulcast;
                    options?['simulcast'] = _simulcast;
                  });
                },
                switchValue: _simulcast,
                leading: _simulcast
                    ? const Icon(Icons.splitscreen_sharp)
                    : const Icon(Icons.splitscreen),
                title: 'Simulcast',
              ),
              SettingsTile.switchTile(
                enabled: true,
                switchValue: _audio,
                leading: const Icon(Icons.headset),
                title: 'Audio',
                onToggle: (bool value) {
                  _audio = !_audio;
                  options?['stereo'] = _audio;
                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<dynamic> popupDialog(
      {required BuildContext context,
      required Key formKey,
      required void Function(dynamic) handler,
      bool state = false,
      bool isTextbox = true,
      bool isDropdown = false}) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Stack(
              clipBehavior: Clip.none,
              children: <Widget>[
                Positioned(
                  right: -40.0,
                  top: -40.0,
                  child: InkResponse(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const CircleAvatar(
                      child: Icon(Icons.close),
                      backgroundColor: Colors.purple,
                    ),
                  ),
                ),
                Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                              child: isTextbox
                                  ? TextField(
                                      enableSuggestions: false,
                                      onSubmitted: handler,
                                      autocorrect: false)
                                  : isDropdown
                                      ? dropdownCodec()
                                      : Checkbox(
                                          value: state, onChanged: handler)))
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  ButtonTheme dropdownCodec() {
    return ButtonTheme(
        alignedDropdown: true,
        child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
          icon: const Icon(Icons.arrow_drop_up),
          iconEnabledColor: Colors.white,
          hint: const Text('Audio Source',
              style: TextStyle(color: Colors.white, fontSize: 15)),
          dropdownColor: Colors.purple,
          items: ['h264', 'vp8', 'vp9'].map((String value) {
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
              options?['codec'] = value;
            });
          },
        )));
  }

  _updateBitrate(num bitrate) async {
    publisherMedia?.updateBandwidth(bitrate);
  }
}
