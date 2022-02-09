# Develop in Millicast SDK

## Development
Follow the installation indicated [here](https://docs.flutter.dev/get-started/install).
Asuming that you have succesfully run `flutter doctor` and your flutter version is 2.8.x or newer and `dart` installed, install the required dependencies running:
```sh
$ flutter pub get
```

### Running demo
If you want to add, fix or edit features in SDK, or just try our demo. 
Before running it, you should add a `.env` file in [exmaple](exapmle) folder. You can find the following example in `.env.sample`:
```sh
# Make a .env file with the following vars
MILLICAST_STREAM_NAME=test
MILLICAST_ACCOUNT_ID=test
MILLICAST_PUBLISH_TOKEN=test
```

Now you can run our demo. Just select your desired device and now you have two options:
```sh
$ flutter run --dart-define="type=publish"
```
To publish a stream. And:
```sh
$ flutter run --dart-define="type=subscribe"
```
To subscribe to a stream.

### Building docs
The SDK documentation is written with [Dartdoc](https://pub.dev/packages/dartdoc), so to build documentation to get HTMLs files run:
```sh
$ dartdoc
```
If you want to navigate docs in your localhost run:
```sh
$ pub global activate dhttpd
$ dhttpd --path doc/api
```
Navigate to `http://localhost:8080` in your browser; the search function should now work.
