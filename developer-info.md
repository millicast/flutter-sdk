# Develop in Millicast Flutter SDK

## Development

Follow the installation indicated [here](https://docs.flutter.dev/get-started/install).
Assuming that you have succesfully run `flutter doctor`, that your flutter version is 2.10.x or newer and `dart` is installed, install the required dependencies running:

```sh
$ flutter pub get
```

> **Note for iOS**: Each time WebRTC dependency gets upgraded, dependency `WebRTC-SDK` has to be updated to the required version in the `ios/millicast_flutter_sdk.podspec` file.
### Running demo

If you want to add, fix or edit features in SDK, or just try our demo, follow these steps:
Before running it, you should add a `.env` file in the [example](example) folder. You can find the following example in `.env.sample`:

```sh
# Make a .env file with the following vars
MILLICAST_STREAM_NAME='my-stream-name'
MILLICAST_ACCOUNT_ID='my-account-id'
MILLICAST_PUBLISH_TOKEN='my-publish-token'
```

In order to get these credentials, you must go to the [Millicast Website](https://www.millicast.com), login and in the dashboard create a new Stream Token. This Stream Token will have all the needed info to set in the `.env` file.

You can now run our demo. Just select your desired device and then run:

```sh
$ flutter run
```

You will be prompted with two buttons in the app main page, you must select in the device whether you would like to publish or subscribe to a stream.

### Building docs

The SDK documentation is written with [Dartdoc](https://pub.dev/packages/dartdoc), so to build documentation to get HTMLs files run:

```
$ dart pub global activate dartdoc
```

to install Dartdoc, and then run:

```sh
$ dartdoc
```

to build the actual documentation.

If you want to navigate docs in your localhost run:

```sh
$ pub global activate dhttpd
$ dhttpd --path doc/api
```

Navigate to `http://localhost:8080` in your browser; the search function should now work.

### Changing classes

Whenever a class is changed, the mock generator should be executed to maintain the test suite working properly.

To do that, in the terminal you should run:

```sh
$ flutter pub run build_runner build
```
