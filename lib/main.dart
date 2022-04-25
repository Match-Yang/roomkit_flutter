import 'dart:math';

import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:roomkit_flutter/roomkit_plugin.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  // TODO contact us to get all this values
  final int productID = 0;
  final int secretID = 0;

  // TODO it's not safe to storage secretSign on client code
  final String secretSign = '';
  final String roomKitTokenUrl =
      'https://roomkit-api.zego.im/auth/get_sdk_token';

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _subject = 'subject';
  String _roomID = '123456';
  String _userName = 'user';
  int _userID = 0;
  ZegoRoomKitRole _role = ZegoRoomKitRole.host;

  // TODO you need to put the token generate code in the server
  //  check this doc for more details: https://docs.zegocloud.com/article/8526
  Future<String> getRoomKitToken() async {
    String secretSign = widget.secretSign.substring(0, 32).toLowerCase();
    int verifyType = 3;
    int version = 1; // Version number. Set it to 1 by default.
    var timestamp = DateTime.now().millisecondsSinceEpoch;
    var deviceIDMap = await RoomKitPlugin.getDeviceID();
    var deviceID = deviceIDMap['deviceID'];
    String sign = md5
        .convert(
            utf8.encode('$secretSign$deviceID$verifyType$version$timestamp'))
        .toString();
    var requestData = {
      'sign': sign,
      'secret_id': widget.secretID,
      'device_id': deviceID,
      'timestamp': timestamp,
    };

    final uri = Uri.parse(widget.roomKitTokenUrl);
    final headers = {'Content-Type': 'application/json'};
    final encoding = Encoding.getByName('utf-8');

    Response response = await post(
      uri,
      headers: headers,
      body: json.encode(requestData),
      encoding: encoding,
    );

    int statusCode = response.statusCode;
    if (statusCode != 200) {
      print('Get RoomKit Token Request Failed: $statusCode');
      return '';
    }
    var responseBody = json.decode(response.body);
    if (responseBody['ret']['code'] != 0) {
      print('Get RoomKit Token Failed: $responseBody');
      return '';
    } else {
      return responseBody['data']['sdk_token'];
    }
  }

  @override
  void initState() {
    RoomKitPlugin.init(widget.secretID).then((value) {
      print('SDK initialized');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RoomKit Demo Home Page"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            TextField(
              decoration: const InputDecoration(labelText: 'Subject'),
              onChanged: (value) => setState(() {
                _subject = value;
              }),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'User Name'),
              onChanged: (value) => setState(() {
                _userName = value;
              }),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'User ID'),
              onChanged: (value) => setState(() {
                _userID = int.parse(value);
              }),
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Room ID'),
              onChanged: (value) => setState(() {
                _roomID = value;
              }),
            ),
            DropdownButton<ZegoRoomKitRole>(
              value: _role,
              elevation: 16,
              onChanged: (ZegoRoomKitRole? newValue) {
                setState(() {
                  _role = newValue!;
                });
              },
              items: const [
                DropdownMenuItem<ZegoRoomKitRole>(
                  value: ZegoRoomKitRole.host,
                  child: Text('Host'),
                ),
                DropdownMenuItem<ZegoRoomKitRole>(
                  value: ZegoRoomKitRole.attendee,
                  child: Text('Attendee'),
                ),
                DropdownMenuItem<ZegoRoomKitRole>(
                  value: ZegoRoomKitRole.assistantHost,
                  child: Text('Assistant Host'),
                ),
              ],
            ),
            TextButton(
                onPressed: () {
                  getRoomKitToken().then((roomkitToken) {
                    ZegoJoinRoomConfig config = ZegoJoinRoomConfig(
                        _userID,
                        _userName,
                        roomkitToken,
                        widget.productID,
                        _roomID,
                        _role);
                    RoomKitPlugin.joinRoom(config, _subject).then((value) {
                      print(value);
                    });
                  });
                },
                child: const Text('Join Room'))
          ],
        ),
      ),
    );
  }
}
