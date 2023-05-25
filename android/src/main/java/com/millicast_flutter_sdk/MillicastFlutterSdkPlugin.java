package com.millicast_flutter_sdk;

import androidx.annotation.NonNull;

// import com.cloudwebrtc.webrtc.utils.EglUtils;

import org.webrtc.DefaultVideoEncoderFactory;
import org.webrtc.EglBase;
import org.webrtc.VideoCodecInfo;

import java.util.ArrayList;
import java.util.Map;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** MillicastFlutterSdkPlugin */
public class MillicastFlutterSdkPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "millicast_flutter_sdk");
    channel.setMethodCallHandler(this);
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
      switch (call.method) {
          case "getSupportedCodecs":
              EglBase eglBase = EglBase.createEgl10(EglBase.CONFIG_PLAIN);
              EglBase.Context eglContext = eglBase == null ? null : eglBase.getEglBaseContext();
              DefaultVideoEncoderFactory dummyEncoderFactory = new DefaultVideoEncoderFactory(
                      eglContext, true, true);
              ArrayList<String> codecs = new ArrayList<String>();
              for (VideoCodecInfo codec : dummyEncoderFactory.getSupportedCodecs()) {
                  codecs.add(codec.name);
              }
              result.success(codecs);
              break;
          case "getPlatformVersion": 
              result.success("Android " + android.os.Build.VERSION.RELEASE);
          default:
              result.notImplemented();
              break;
      }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }
}
