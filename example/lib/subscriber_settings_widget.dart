import 'package:example/utils/constants.dart';
import 'package:example/viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:logger/logger.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
import 'package:millicast_flutter_sdk/src/view.dart' as millicast_view;

Logger _logger = getLogger('SubscriberSettings');
var simulcastQualityValue = 'Auto';

class SubscriberSettingsWidget extends StatefulWidget {
  final millicast_view.View? view;
  final Map? options;
  const SubscriberSettingsWidget({this.view, this.options, Key? key})
      : super(key: key);
  @override
  SubscriberSettingsWidgetState createState() =>
      // ignore: no_logic_in_create_state
      SubscriberSettingsWidgetState(view: view, options: options);
}

class SubscriberSettingsWidgetState extends State<SubscriberSettingsWidget> {
  Map? options;
  final _formKey = GlobalKey<FormState>();
  millicast_view.View? view;

  SubscriberSettingsWidgetState({required this.view, required this.options});

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
                leading: const Icon(Icons.view_stream),
                title: 'Stream Name',
                onPressed: (BuildContext context) {
                  popupDialog(
                      currentValue: Constants.streamName,
                      context: context,
                      formKey: _formKey,
                      handler: (value) {
                        Constants.streamName = value;
                        _logger.i(Constants.streamName);
                      });
                },
              ),
              SettingsTile(
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
                leading: const Icon(Icons.perm_identity),
                title: 'MultiSource',
                enabled: isMultisourceEnabled,
                onPressed: (BuildContext context) {
                  showDialog(
                      context: context,
                      builder: (builder) => AlertDialog(
                            title: const Text('Select Sources'),
                            actions: [
                              generateMultiSourceAlert(
                                  'Video', selectedVideoSource),
                              generateMultiSourceAlert(
                                  'Audio', selectedAudioSource)
                            ],
                          ));
                },
              ),
              SettingsTile(
                leading: const Icon(Icons.perm_identity),
                title: 'Simulcast',
                enabled: isSimulcastEnabled,
                onPressed: (BuildContext context) {
                  showDialog(
                      context: context,
                      builder: (builder) => AlertDialog(
                            title: const Text('Video Quality'),
                            actions: [
                              StatefulBuilder(builder:
                                  (BuildContext context, StateSetter setState) {
                                return Container(
                                    decoration: BoxDecoration(
                                        color: Colors.purple,
                                        borderRadius:
                                            BorderRadius.circular(15)),
                                    padding: const EdgeInsets.only(
                                      left: 1,
                                    ),
                                    child: ButtonTheme(
                                      alignedDropdown: true,
                                      child: DropdownButtonHideUnderline(
                                          child: DropdownButton<String>(
                                        icon: const Icon(Icons.arrow_drop_up),
                                        iconEnabledColor: Colors.white,
                                        hint: const Text('Video Quality',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 15)),
                                        dropdownColor: Colors.purple,
                                        items:
                                            currentLayers.map((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(
                                              value,
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          );
                                        }).toList(),
                                        onChanged: (value) {
                                          setState(() {
                                            simulcastQualityValue = value!;
                                            switch (simulcastQualityValue) {
                                              case 'Auto':
                                                view?.select();
                                                break;
                                              case 'High':
                                                if (currentLayers.length > 3) {
                                                  view?.select(layer: {
                                                    'encodingId': '2'
                                                  });
                                                } else {
                                                  view?.select(layer: {
                                                    'encodingId': '1'
                                                  });
                                                }

                                                break;
                                              case 'Medium':
                                                view?.select(
                                                    layer: {'encodingId': '1'});
                                                break;
                                              case 'Low':
                                                view?.select(
                                                    layer: {'encodingId': '0'});
                                                break;
                                              default:
                                            }
                                          });
                                        },
                                        value: simulcastQualityValue,
                                      )),
                                    ));
                              })
                            ],
                          ));
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
                      backgroundColor: Colors.purple,
                      child: Icon(Icons.close),
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
                              child: TextField(
                                  controller:
                                      TextEditingController(text: currentValue),
                                  enableSuggestions: false,
                                  onSubmitted: handler,
                                  autocorrect: false)))
                    ],
                  ),
                ),
              ],
            ),
          );
        });
  }

  Future<void> _projectSourceId(String? value, String type) async {
    if (value == 'Main') {
      value = null;
    }
    await view?.project(value, [
      {'trackId': type, 'mediaId': type == 'video' ? '0' : '1'},
    ]);
    if (type == 'video') {
      selectedVideoSource = type == 'video' ? value : null;
    } else {
      selectedAudioSource = type == 'audio' ? value : null;
    }

    isSimulcastEnabled = !isSimulcastEnabled;
    setState(() {});
  }

//Generates a container based on type(audio or video) for multisourcing
  generateMultiSourceAlert(String type, source) {
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
            child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
              icon: const Icon(Icons.arrow_drop_up),
              iconEnabledColor: Colors.white,
              value: source,
              hint: Text('$type Source',
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
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
                  source = value;
                  _projectSourceId(value, type.toLowerCase());
                });
              },
            )),
          ));
    });
  }
}
