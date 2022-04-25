package com.zegocloud.roomkit_flutter

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity: FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        val pluginHandler = RoomKitPlugin()

        val messenger = flutterEngine.dartExecutor.binaryMessenger
        val channel = MethodChannel(messenger, "RoomKitPlugin")

        channel.setMethodCallHandler { call, result ->
            when(call.method) {
                "init" -> { pluginHandler.init(call, result, application) }
                "joinRoom" -> { pluginHandler.joinRoom(call, result, this@MainActivity) }
                "getDeviceID" -> { pluginHandler.getDeviceID(call, result) }
                else -> { result.error("error_code", "error_message", null) }
            }
        }
    }
}
