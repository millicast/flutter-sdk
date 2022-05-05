import 'package:example/utils/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';
import 'home_screen.dart';
import 'publisher_widget.dart';
import 'subscriber_widget.dart';
import 'publisher_settings_widget.dart';
import 'package:uni_links/uni_links.dart';
import 'package:flutter/services.dart' show PlatformException;

Logger _logger = getLogger('main');
void main() async {
  Logger.level = Level.info;
  await dotenv.load(fileName: '.env');
  await initUniLinks();
  runApp(const MyApp());
}

Future<bool> initUniLinks() async {
  try {
    Uri? initialLink = await getInitialUri();
    _logger.i(initialLink);
    if (initialLink != null) {
      String? streamId = initialLink.queryParameters['streamId'];
      if (streamId == null) {
        return false;
      }
      RegExp match = RegExp(r'(.*)(\/)(.*)', multiLine: true);
      var matches = match.allMatches(streamId);
      try {
        String accountId = matches.first[1]!;
        String streamName = matches.first[3]!;
        Constants.setConstants(
            newAccountId: accountId, newStreamName: streamName);
        return true;
      } catch (e) {
        _logger.w('Invalid StreamId');
        return false;
      }
    }
  } on PlatformException {
    _logger.e('Platform exception unilink');
    return false;
  }
  return false;
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
          primarySwatch: Colors.purple, secondaryHeaderColor: Colors.purple),
      initialRoute: '/',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        // '/': (context) => const HomeScreen(),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/publisher': (context) => const PublisherWidget(),
        '/subscriber': (context) => const SubscriberWidget(),
        '/settings': (context) => const PublisherSettingsWidget(
              isConnected: false,
              supportedCodecs: [],
            )
      },
      home: HomeScreen(),
    );
  }
}
