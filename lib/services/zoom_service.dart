import 'package:flutter/services.dart';

class ZoomService {
  static const platform = MethodChannel('com.example.video_calling_app/zoom');
  ZoomService();
  Future<void> initialize() async {
    try {
      final result = await platform.invokeMethod('initializeZoomSdk');
      print(result);
    } on PlatformException catch (e) {
      print("Failed to initialize Zoom SDK: '${e.message}'.");
    }
  }

  Future<void> joinMeeting(String sessionName, String sessionPassword) async {
    try {
      final result = await platform.invokeMethod('joinMeeting', {
        'sessionName': sessionName,
        'sessionPassword': sessionPassword,
      });
      print(result);
    } on PlatformException catch (e) {
      print("Failed to join meeting: '${e.message}'.");
    }
  }

  Future<void> startMeeting(String sessionName) async {
    try {
      final result = await platform.invokeMethod('startMeeting', {
        'sessionName': sessionName,
      });
      print(result);
    } on PlatformException catch (e) {
      print("Failed to start meeting: '${e.message}'.");
    }
  }
}
