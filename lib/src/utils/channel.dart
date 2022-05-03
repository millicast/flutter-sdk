import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class NativeChannel {
  static const MethodChannel _channel = MethodChannel('millicast_flutter_sdk');

  static Future<String?> get platformVersion async {
    final String? version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<List<Object?>> get supportedCodecs async {
    List<Object?> codecs = [
      'vp8',
      'vp9',
      'h264',
      'av1',
    ];
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        codecs = await _channel.invokeMethod('getSupportedCodecs');
      }
    }
    return codecs;
  }
}
