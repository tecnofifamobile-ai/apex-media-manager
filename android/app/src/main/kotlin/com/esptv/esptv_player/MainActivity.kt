package com.esptv.esptv_player

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.UiModeManager
import android.content.Context
import android.content.res.Configuration
import android.content.pm.ActivityInfo
import android.os.Build

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        val mode = getSystemService(Context.UI_MODE_SERVICE) as UiModeManager
        val isTv = mode.currentModeType == Configuration.UI_MODE_TYPE_TELEVISION
        if (isTv) requestedOrientation = ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "apex/device")
            .setMethodCallHandler { call, result ->
                if (call.method == "isTelevision") result.success(isTv)
                else if (call.method == "primaryAbi") result.success(Build.SUPPORTED_ABIS.firstOrNull {
                    it in setOf("arm64-v8a", "armeabi-v7a", "x86_64")
                } ?: Build.SUPPORTED_ABIS.firstOrNull())
                else result.notImplemented()
            }
    }
}
