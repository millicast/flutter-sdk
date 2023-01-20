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

  static Future<List<String>> get supportedCodecs async {
    List<String> codecs = [
      'vp8',
      'vp9',
      'h264',
      'av1',
    ];
    if (!kIsWeb) {
      if (Platform.isAndroid) {
        List<Object?> codecsObject =
            await _channel.invokeMethod('getSupportedCodecs');
        List<String> codecs = [];
        codecs = codecsObject
            .map((codec) => (codec as String).toLowerCase())
            .toList();
        return codecs;
      }
      if (Platform.isMacOS) {
        // Not supported, needs further investigation
        codecs.remove('vp9');
      }
    }
    return codecs;
  }
}
