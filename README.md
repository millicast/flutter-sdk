# Millicast SDK for Flutter
Flutter SDK for building a realtime broadcaster using the Millicast platform.
This Software Development Kit (SDK) for Flutter allows developers to simplify Millicast services integration into their own Android and iOS apps.
## Table of Contents
* [Installation](#installation)
* [Basic Usage](#basic-usage)
* [API Reference](#api-reference)
* [Samples](#samples)
* [SDK developer information](#sdk-developer-information)
* [License](#license)
## Installation (WIP)
```sh
$ flutter pub add millicast_flutter_sdk
```

## Basic Usage (WIP)
When creating your own app, follow these steps:
Add `flutter_webrtc` as a [dependency in your pubspec.yaml file](https://flutter.io/using-packages/).
### iOS

Add the following entry to your _Info.plist_ file, located in `<project root>/ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) Camera Usage!</string>
<key>NSMicrophoneUsageDescription</key>
<string>$(PRODUCT_NAME) Microphone Usage!</string>
```

This entry allows your app to access camera and microphone.

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
If you need to use a Bluetooth device, please add:
```xml
<uses-permission android:name="android.permission.BLUETOOTH" />
<uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
```
The Flutter project template adds it, so it may already be there.
Also you will need to set your build settings to Java 8, because official WebRTC jar now uses static methods in `EglBase` interface. Just add this to your app level `build.gradle`:

```groovy
android {
    //...
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
}
```
If necessary, in the same `build.gradle` you will need to increase `minSdkVersion` of `defaultConfig` up to `21` (currently default Flutter generator set it to `16`).
### Important reminder
When you compile the release apk, you need to add the following operations,
[Setup Proguard Rules](https://github.com/flutter-webrtc/flutter-webrtc/commit/d32dab13b5a0bed80dd9d0f98990f107b9b514f4)
## API Reference (WIP)
You can find the latest, most up to date, SDK documentation at our [API Reference page](https://millicast.github.io/millicast-sdk/). There are more examples with every module available. 
## Samples (WIP)
Example can be found in [example](example) folder.
## SDK developer information (WIP)
To develop and contribute to this project, there are some instructions of how to set up your environment to start contributing. [Follow this link](developer-info.md).

## License (WIP)

Please refer to [LICENSE](LICENSE) file.
