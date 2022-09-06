import 'dart:async';

import 'package:flutter/services.dart';

enum ZegoRoomKitRole {
  host,
  attendee,
  assistantHost,
}

extension ZegoRoomKitRoleExtension on ZegoRoomKitRole {
  int get value {
    switch (this) {
      case ZegoRoomKitRole.host:
        return 1;
      case ZegoRoomKitRole.attendee:
        return 2;
      case ZegoRoomKitRole.assistantHost:
        return 4;
      default:
        return 2;
    }
  }
}

// For more details, check: https://docs.zegocloud.com/article/api?doc=RoomKit_API~java_android~class~ZegoJoinRoomConfig
class ZegoJoinRoomConfig {
  // User ID (Required)
  int userID;

  // User's Nickname (Required)
  String userName;

  // Obtained by calling RoomKit REST API "get_sdk_token" (Required)
  String sdkToken;

  // ProductID of the room (Required), Note: Please contact our technical support to get this.
  int productID;

  // ID of the room (Required)
  String roomID;

  // The role of the user, there are three kinds of students, teaching assistants, and teachers (Required)
  ZegoRoomKitRole role;

  ZegoJoinRoomConfig(this.userID, this.userName, this.sdkToken, this.productID,
      this.roomID, this.role);
}

class RoomKitPlugin {
  static const MethodChannel channel = MethodChannel('RoomKitPlugin');

  // Init roomkit sdk with [secretID] on application startup.
  //
  // Note: You should only call the method once in the application life cycle
  static Future<void> init(int secretID) async {
    return await channel.invokeMethod("init", {"secretID": secretID});
  }

  // Join room with parameters and return error code with 0 if successes.
  //
  // When you join room with [role] as host, it will create a new room if it's not exist.
  // [joinRoomConfig] Join room parameter configuration
  // [subject] Set the topic of the room
  // [avatarUrl] Set user avatar during chat
  static Future<Map> joinRoom(ZegoJoinRoomConfig joinRoomConfig, String subject,
      {String avatarUrl = ''}) async {
    return await channel.invokeMethod("joinRoom", {
      "userName": joinRoomConfig.userName,
      "userID": joinRoomConfig.userID,
      "roleType": joinRoomConfig.role.value,
      "roomID": joinRoomConfig.roomID,
      "productID": joinRoomConfig.productID,
      "sdkToken": joinRoomConfig.sdkToken,
      "avatarUrl": avatarUrl,
      "subject": subject
    });
  }

  // Get device's id for generate roomkit sdk token
  static Future<Map> getDeviceID() async {
    return await channel.invokeMethod("getDeviceID", {});
  }

  // set microphone on/off when you join room
  static Future<void> setIsMicrophoneOnWhenJoiningRoom(bool isOn) async {
    return await channel
        .invokeMethod("setIsMicrophoneOnWhenJoiningRoom", {'isOn': isOn});
  }

  // set camera on/off when you join room
  static Future<void> setIsCameraOnWhenJoiningRoom(bool isOn) async {
    return await channel
        .invokeMethod("setIsCameraOnWhenJoiningRoom", {'isOn': isOn});
  }
}
