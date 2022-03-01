import 'package:example/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:logger/logger.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

Logger _logger = getLogger('SubscriberSettings');

class SubscriberSettingsWidget extends StatefulWidget {
  final View? view;
  final Map? options;
  const SubscriberSettingsWidget({this.view, this.options, Key? key})
      : super(key: key);
  @override
  _SubscriberSettingsWidgetState createState() =>
      // ignore: no_logic_in_create_state
      _SubscriberSettingsWidgetState(view: view, options: options);
}

class _SubscriberSettingsWidgetState extends State<SubscriberSettingsWidget> {
  Map? options;
  final _formKey = GlobalKey<FormState>();
  View? view;

  _SubscriberSettingsWidgetState({required this.view, required this.options});

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
                      context: context,
                      formKey: _formKey,
                      handler: (value) {
                        Constants.accountId = value;
                        _logger.i(Constants.accountId);
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
                              child: TextField(
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
}
