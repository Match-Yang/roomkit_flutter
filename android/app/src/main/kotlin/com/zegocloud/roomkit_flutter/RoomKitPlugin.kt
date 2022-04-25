package com.zegocloud.roomkit_flutter
import android.app.Application
import io.flutter.app.FlutterActivityEvents
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.json.JSONArray
import org.json.JSONObject
import java.util.ArrayList
import im.zego.roomkit.service.ZegoJoinRoomUIConfig
import im.zego.roomkit.service.ZegoRoomKit
import im.zego.roomkitcore.service.*
import android.app.Activity

class RoomKitPlugin: EventChannel.StreamHandler {
    fun init(call: MethodCall, result: MethodChannel.Result , application: Application) {
        val secretID: Int? = call.argument<Int>("secretID")
        val config = ZegoInitConfig()
        config.secretID = secretID?.toLong()!!
        ZegoRoomKit.init(config, { error ->
            if (error == ZegoRoomKitError.SUCCESS) {
                result.success(null)
                }
        }, application)
    }

    fun joinRoom(call: MethodCall, result: MethodChannel.Result, activity: Activity) {
        val userName: String? = call.argument<String>("userName")
        val userID: Int? = call.argument<Int>("userID")
        val roomID: String? = call.argument<String>("roomID")
        val productID: Int? = call.argument<Int>("productID")
        val roleType: Int? = call.argument<Int>("roleType")
        val sdkToken: String? = call.argument<String>("sdkToken")
        val subject: String? = call.argument<String>("subject")
        val avatarUrl: String? = call.argument<String>("avatarUrl")

        val joinConfig = ZegoJoinRoomConfig()
        joinConfig.userName = userName
        joinConfig.userID = userID?.toLong()!!
        joinConfig.roomID = roomID
        joinConfig.productID = productID!!
        if (roleType == 1) {
            joinConfig.role = ZegoRoomKitRole.Host
        } else if (roleType == 2) {
            joinConfig.role = ZegoRoomKitRole.Attendee
        } else if (roleType == 4) {
            joinConfig.role = ZegoRoomKitRole.AssistantHost
        } else {
            joinConfig.role = ZegoRoomKitRole.Attendee
        }
        joinConfig.sdkToken = sdkToken
        val inRoomService = ZegoRoomKit.getInRoomService()
        // 加入房间前设置一些参数
        val roomParameter = ZegoRoomParameter()
        val userParameter = ZegoUserParameter()
        val uiConfig = ZegoJoinRoomUIConfig()
        uiConfig.isMinimizeHidden = true
        userParameter.avatarUrl = avatarUrl
        roomParameter.subject = subject

        inRoomService.setUIConfig(uiConfig)
        inRoomService.setRoomParameter(roomParameter)
        inRoomService.setUserParameter(userParameter)

        inRoomService.joinRoom(joinConfig, activity) { errorCode ->
            result.success(mapOf("errorCode" to errorCode.value()))
        }
    }

    fun getDeviceID(call: MethodCall, result: MethodChannel.Result) {
        val deviceID = ZegoRoomKit.getDeviceID()
        result.success(mapOf("deviceID" to deviceID))
    }


    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {

    }

    override fun onCancel(arguments: Any?) {

    }
}