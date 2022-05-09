## 0.2.1

This is the first official release of the Millicast Flutter SDK.

### Added

- Now the SDK can be directly downloaded from pub.dev package repository.
- getCapabilities initial implementation now returns supported video codecs.

### Changed

- Example app now only renders supported codecs in the settings widget.

### Fixed

- EA-Mirror-iOS-Camera: invert mirrored flag.
- Bugfix/h264-support: Fallback to supported codec.
- h264-support: solved codec fallback codec issue. by @fcancela in https://github.com/millicast/flutter-sdk/pull/17

**Full Changelog**: https://github.com/millicast/flutter-sdk/compare/0.2.0...0.2.1

### Fixed

- H264 publish on Android is device dependent.

## 0.2.0

### Added

- Added support for latest version of viewercount.

### Changed

- Removed support for legacy version of viewercount.
- Updated README API Reference hyperlink to the proper url.

### Fixed

- Fixed viewercount issues for EA.
- Fixed EA iOS bug where audio could not be heard on the subscriber side.
- Fixed bug where websockets were not being properly closed both for publisher/viewer.
- Fixed reenabling unlimited bitrate for the SDK.

**Full Changelog**: https://github.com/millicast/flutter-sdk/compare/0.1.0...0.2.0

## 0.1.0

This is the first beta test release of the Millicast Flutter SDK.

For SDK usage instructions, please refer to the SDK [README.md](https://github.com/millicast/flutter-sdk/tree/0.1.0#readme).
An Example App (EA) at [flutter-sdk/example](https://github.com/millicast/flutter-sdk/tree/0.1.0/example) has been provided to illustrate the basic usage of the SDK.
Usage of the EA is documented at its own readme at [flutter-sdk/example/README.md](https://github.com/millicast/flutter-sdk/tree/0.1.0/example#readme).

There are some known issues as indicated below that are currently being worked on.

Known issues:

- H264 publish on Android is device dependent.
  - Possible workaround includes publishing with other codecs, such as VP8, VP9.
- The EA has some minor issues:
  - On iOS, the first publish might be missing audio.
    - Possible workaround is to exit, reenter Publisher view, and publish again.
  - Viewer count might not work correctly in some scenarios.
  - Subscription occasionally does not terminate after leaving Subscriber view.
    - Possible workaround is to restart EA.
