# Millicast SDK for Flutter

Flutter SDK for building a realtime broadcaster using the Millicast platform.
This Software Development Kit (SDK) for Flutter allows developers to simplify Millicast services integration into their own Android and iOS mobile apps, and Windows, Linux and MacOS desktop apps.

> **Note**: Desktop support (Windows, Linux and MacOS) is still on beta state as it's under development.

## Table of Contents

- [Installation](#installation)
  - [iOS and MacOS](#ios-and-macos)
  - [MacOS](#macos)
  - [Android](#android)
- [Basic Usage](#basic-usage)
  - [Main app](#main-app)
  - [Publisher app](#publisher-app)
  - [Viewer app](#viewer-app)
  - [Important reminder](#important-reminder)
- [API Reference](#api-reference)
- [Sample](#sample)
- [SDK developer information](#sdk-developer-information)
- [License](#license)

## Installation

To add the Millicast Flutter SDK to your dependencies, run:

```sh
flutter pub add millicast_flutter_sdk
```

Then run the following command to download the dependencies:

```sh
flutter pub get
```

With this you will have then access to all the features provided by the SDK to use in your project.

When creating your own app, follow these steps:
Add `flutter_webrtc` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).

You will need a Millicast account and a valid publishing token that you can find it in your dashboard ([link here](https://dash.millicast.com/#/signin)).

### iOS and MacOS

Add the following entry to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist` and `<project root>/macos/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) Camera Usage!</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) Microphone Usage!</string>
```

This entry allows your app to access the camera and microphone.

### MacOS 

To add specific capabilities or services on your macOS app, such as access to internet, capture media from the integrated camera and microphone devices, then you must set up specific entitlements to your _DebugProfile.entitlements_ (for debug and profile builds) and _Runner.entitlements_ (for release builds) files.

At `<project root>/macos/Runner/DebugProfile.entitlements` and `<project root>/macos/Runner/Release.entitlements` add the following entrys:

```xml
<key>com.apple.security.network.server</key>
<true/>
<key>com.apple.security.device.camera</key>
<true/>
<key>com.apple.security.device.audio-input</key>
<true/>
<key>com.apple.security.network.client</key>
```

Also give your app access to use your camera and mic. Go to **Apple menu  > System Preferences > Privacy & Security > Privacy**. There unlock the lock icon in the lower-left to allow you to make changes to your preferences. Then, for both the camera and the microphone, select the respective icon and then enable the toggle next to your app to allow access to the device.

### Android

Ensure the following permission is present in your Android Manifest file, located in `<project root>/android/app/src/main/AndroidManifest.xml`:

```xml
<uses-feature android:name="android.hardware.camera" />
<uses-feature android:name="android.hardware.camera.autofocus" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
<uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
```

If you need to use a Bluetooth device, add:

```xml
<uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />
<uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />
```

The Flutter project template adds it, so it may already be there.
You will also need to set your build settings to Java 8, because the official WebRTC jar now uses static methods in `EglBase` interface. Just add this to your app level `build.gradle`:

```groovy
android {
    //...
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```

If necessary, in the same `build.gradle` you will need to increase `minSdkVersion` of `defaultConfig` up to `23` (currently default Flutter generator set it to `16`).

## Basic Usage

This is a simple Minimum V P of our project to show the publish or subscribing features. You will need to put the following three code snippets in the respective `main.dart`, `publisher.dart` and `viewer.dart` files, and set your Millicast streaming credentials where needed in order to test it.

### Main app

```dart
import 'publisher.dart';
import 'viewer.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter/material.dart';

const type = String.fromEnvironment('type');
void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Millicast SDK Demo',
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
  @override
  void dispose() {
    _localRenderer.dispose();
    super.dispose();
  }

  @override
  void initState() {
    initRenderers();
    // Run application with --dart-define type flag like:
    // flutter run --dart-define=type="subscribe||publish"
    // To choose wether you want to publishe or subscribe.
    switch (type) {
      case 'subscribe':
        subscribeExample();
        break;
      case 'publish':
        publishExample();
        break;
      default:
        publishExample();
    }
    super.initState();
  }

  void publishExample() async {
    await publishConnect(_localRenderer);
    setState(() {});
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
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return RotatedBox(
              quarterTurns: 1,
              child: Center(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height,
                  child: RTCVideoView(_localRenderer, mirror: true),
                  decoration: const BoxDecoration(color: Colors.black54),
                ),
              ));
        },
      ),
    );
  }
}
```

### Publisher app

```dart
import 'dart:io';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

Future publishConnect(RTCVideoRenderer localRenderer) async {
  // Setting subscriber options
  DirectorPublisherOptions directorPublisherOptions = DirectorPublisherOptions(
      token: 'my-publishing-token', streamName: 'my-stream-name');

  /// Define callback for generate new token
  tokenGenerator() => Director.getPublisher(directorPublisherOptions);

  /// Create a new instance
  Publish publish =
      Publish(streamName: 'my-streamname', tokenGenerator: tokenGenerator);

  final Map<String, dynamic> constraints = <String, bool>{
    'audio': true,
    'video': true
  };

  MediaStream stream = await navigator.mediaDevices.getUserMedia(constraints);
  localRenderer.srcObject = stream;

  //Publishing Options
  Map<String, dynamic> broadcastOptions = {'mediaStream': stream};
  //Some Android devices do not support h264 codec for publishing
  if (Platform.isAndroid) {
    broadcastOptions['codec'] = 'vp8';
  }

  /// Start connection to publisher
  try {
    await publish.connect(options: broadcastOptions);
    return publish.webRTCPeer;
  } catch (e) {
    throw Exception(e);
  }
}
```

### Viewer app

```dart
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:millicast_flutter_sdk/millicast_flutter_sdk.dart';

Future viewConnect(RTCVideoRenderer localRenderer) async {
  // Setting subscriber options
  DirectorSubscriberOptions directorSubscriberOptions =
      DirectorSubscriberOptions(
          streamAccountId: 'my-account-id', streamName: 'my-stream-name');

  /// Define callback for generate new token
  tokenGenerator() => Director.getSubscriber(directorSubscriberOptions);

  /// Create a new instance
  View view = View(
      streamName: 'my-stream-name',
      tokenGenerator: tokenGenerator,
      mediaElement: localRenderer);

  /// Start connection to publisher
  try {
    await view.connect();
    return view.webRTCPeer;
  } catch (e) {
    rethrow;
  }
}
```

### Run the application

Set `type` environment variable `publish` or `subscribe` to decide wether you want to run the publisher or viewer app.

```bash
flutter run --dart-define=type='publish'
```

### Important reminder

When you compile the release apk, you need to add the following operations:
[Setup Proguard Rules](https://github.com/flutter-webrtc/flutter-webrtc/commit/d32dab13b5a0bed80dd9d0f98990f107b9b514f4)

## API Reference

You can find the latest, most up to date SDK documentation at our [API Reference page](https://pub.dev/documentation/millicast_flutter_sdk/latest/). There are more examples with every module available.

## Sample

Example can be found in [example](example) folder.

## SDK developer information

To develop and contribute to this project, there are some instructions on how to set up your environment to start contributing. [Follow this link](developer-info.md).

## License

Please refer to [LICENSE](LICENSE) file.
