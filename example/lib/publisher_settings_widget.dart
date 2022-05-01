import 'package:example/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:logger/logger.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

import 'millicast_publisher_user_media.dart';

Logger _logger = getLogger('PublisherSettings');

class PublisherSettingsWidget extends StatefulWidget {
  final MillicastPublishUserMedia? publisherMedia;
  final Map? options;
  final bool isConnected;
  final List<String> supportedCodecs;
  const PublisherSettingsWidget(
      {this.publisherMedia,
      required this.supportedCodecs,
      this.options,
      required this.isConnected,
      Key? key})
      : super(key: key);
  @override
  _PublisherSettingsWidgetState createState() =>
      // ignore: no_logic_in_create_state
      _PublisherSettingsWidgetState(
          publisherMedia: publisherMedia,
          supportedCodecs: supportedCodecs,
          options: options,
          isConnected: isConnected);
}

class _PublisherSettingsWidgetState extends State<PublisherSettingsWidget> {
  Map? options;
  bool isConnected;
  final _formKey = GlobalKey<FormState>();
  MillicastPublishUserMedia? publisherMedia;
  bool isSimulcastEnabled = true;
  List<String> supportedCodecs = ['h264', 'vp8', 'vp9', 'av1'];

  _PublisherSettingsWidgetState(
      {required this.publisherMedia,
      required this.supportedCodecs,
      required this.options,
      required this.isConnected});

  @override
  Widget build(BuildContext context) {
    int _bitrate = options?['bandwidth'] ?? 0;
    bool _audio = options?['stereo'] ?? false;
    bool _simulcast = options?['simulcast'] ?? false;

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
                enabled: !isConnected,
                onPressed: (BuildContext context) {
                  popupDialog(
                      currentValue: options?['sourceId'],
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
                      currentValue: _bitrate.toString(),
                      context: context,
                      formKey: _formKey,
                      isTextbox: true,
                      handler: (value) {
                        _bitrate = value != null ? int.parse(value) : 0;
                        options?['bandwidth'] = _bitrate;
                        if (isConnected) {
                          _updateBitrate(_bitrate);
                        }
                      });
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.splitscreen_sharp),
                enabled: !isConnected,
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
                enabled: (!isConnected && isSimulcastEnabled),
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
                enabled: !isConnected,
                switchValue: _audio,
                leading: const Icon(Icons.headset),
                title: 'Audio',
                onToggle: (bool value) {
                  _audio = !_audio;
                  options?['stereo'] = _audio;
                  setState(() {});
                },
              ),
              SettingsTile(
                enabled: !isConnected,
                leading: const Icon(Icons.view_stream),
                title: 'Stream Name',
                onPressed: (BuildContext context) {
                  popupDialog(
                      currentValue: Constants.streamName,
                      context: context,
                      formKey: _formKey,
                      handler: (value) {
                        options?['streamName'] = value;
                        Constants.streamName = value;
                      });
                },
              ),
              SettingsTile(
                enabled: !isConnected,
                leading: const Icon(Icons.perm_identity),
                title: 'Account Id',
                onPressed: (BuildContext context) {
                  popupDialog(
                      currentValue: Constants.accountId,
                      context: context,
                      formKey: _formKey,
                      handler: (value) {
                        options?['accountId'] = value;
                        Constants.accountId = value;
                      });
                },
              ),
              SettingsTile(
                enabled: !isConnected,
                leading: const Icon(Icons.token),
                title: 'Publish Token',
                onPressed: (BuildContext context) {
                  popupDialog(
                      currentValue: Constants.publishToken,
                      context: context,
                      formKey: _formKey,
                      handler: (value) {
                        options?['publishToken'] = value;
                        Constants.publishToken = value;
                      });
                },
              )
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
      String? currentValue,
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
                                      controller: TextEditingController(
                                          text: currentValue),
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

  StatefulBuilder dropdownCodec() {
    return StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
      return Container(
        decoration: BoxDecoration(
            color: Colors.purple, borderRadius: BorderRadius.circular(15)),
        padding: const EdgeInsets.only(
          left: 1,
        ),
        child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButton<String>(
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down),
              iconEnabledColor: Colors.white,
              hint: const Text('vp8',
                  style: TextStyle(color: Colors.white, fontSize: 15)),
              dropdownColor: Colors.purple,
              value: options?['codec'],
              items: supportedCodecs.map((String value) {
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
                  if (value == 'vp9' || value == 'av1') {
                    super.setState(() {
                      isSimulcastEnabled = false;
                      options?['simulcast'] = false;
                    });
                  } else {
                    super.setState(() {
                      isSimulcastEnabled = true;
                    });
                  }
                  options?['codec'] = value;
                });
              },
            )),
      );
    });
  }

  _updateBitrate(num bitrate) async {
    if (publisherMedia != null) {
      publisherMedia?.updateBandwidth(bitrate);
    } else {
      _logger.w('Please await until a publisherMedia has been defined.');
    }
  }
}
