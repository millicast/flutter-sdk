import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'home_screen.dart';
import 'publisher_widget.dart';
import 'subscriber_widget.dart';
import 'publisher_settings_widget.dart';

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
      home: const HomeScreen(),
    );
  }
}
