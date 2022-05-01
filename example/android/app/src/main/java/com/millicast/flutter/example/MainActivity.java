package com.millicast.flutter.example;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import android.content.ContextWrapper;
import android.content.Intent;
import android.content.IntentFilter;

import android.os.BatteryManager;
import android.os.Build.VERSION;
import android.os.Build.VERSION_CODES;
import android.os.Bundle;

import org.webrtc.DefaultVideoEncoderFactory;
import org.webrtc.VideoCodecInfo;
import org.webrtc.DtmfSender;
import org.webrtc.EglBase;

import com.cloudwebrtc.webrtc.utils.EglUtils;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;

import java.util.ArrayList;

public class MainActivity extends FlutterActivity {
    private static final String CHANNEL = "sample.millicast.app/fluttersdk";

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(
                        (call, result) -> {
                            switch (call.method) {
                                case "getSupportedCodecs":
                                    EglBase.Context eglContext = EglUtils.getRootEglBaseContext();
                                    DefaultVideoEncoderFactory dummyEncoderFactory = new DefaultVideoEncoderFactory(
                                            eglContext, true, true);
                                    ArrayList<String> codecs = new ArrayList<String>();
                                    for (VideoCodecInfo codec : dummyEncoderFactory.getSupportedCodecs()) {
                                        codecs.add(codec.name);
                                    }
                                    result.success(codecs);
                                    break;
                                default:
                                    result.notImplemented();
                                    break;
                            }
                        });
    }
}
