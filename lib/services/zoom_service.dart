import 'dart:async';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';

class ZoomService {
  final String sdkKey;
  final String sdkSecret;
  final ZoomVideoSdk _zoomVideoSdk = ZoomVideoSdk();

  ZoomService(this.sdkKey, this.sdkSecret);

  // Generate JWT Token for SDK authentication
  String generateJwtToken(String sessionName) {
    final jwt = JWT({
      'app_key': sdkKey,
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,
      'tpc': sessionName,
      'role_type': 1, // 1 for host, 0 for participant
    });
    return jwt.sign(SecretKey(sdkSecret));
  }

  // Initialize the Zoom SDK
  Future<void> initialize() async {
    try {
      print('Entering initializing Zoom SDK ++++++++++++++++++++++++++:');
      await _zoomVideoSdk.initSdk(
        InitConfig(domain: 'zoom.us', enableLog: true),
      );
    } catch (e) {
      print('Error initializing Zoom SDK: $e');
    }
  }

  // Join a Zoom session/meeting
  Future<void> joinMeeting(String sessionName, String sessionPassword) async {
    try {
      final token = generateJwtToken(sessionName);
      JoinSessionConfig joinSession = JoinSessionConfig(
        sessionName: sessionName,
        sessionPassword: sessionPassword,
        token: token,
        userName: "YourName",
        audioOptions: {"connect": true, "mute": false},
        videoOptions: {"localVideoOn": true},
      );

      await _zoomVideoSdk.joinSession(joinSession);
    } catch (e) {
      print('Error joining meeting: $e');
    }
  }


  // Start a Zoom session/meeting
  Future<void> startMeeting(String sessionName) async {
    try {
      final token = generateJwtToken(sessionName);

      JoinSessionConfig startSession = JoinSessionConfig(
        sessionName: sessionName,
        token: token,
        userName: "YourName",
        audioOptions: {"connect": true, "mute": false},
        videoOptions: {"localVideoOn": true},
      );

      await _zoomVideoSdk.joinSession(startSession);
    } catch (e) {
      print('Error starting meeting: $e');
    }
  }
}
