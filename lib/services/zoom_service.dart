import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:flutter_zoom_videosdk/native/zoom_videosdk.dart';

class ZoomService {
  static const String sdkKey = '4EWtf96CozmNxQwZu5LWO3gvojDqCJAq963S';  // Replace with your SDK Key
  static const String sdkSecret = '2GEaEgblthLBOYcKjz6rbXswWsQgYMOyHrYu';  // Replace with your SDK Secret

  final ZoomVideoSdk _zoomVideoSdk = ZoomVideoSdk();

  // Method to generate JWT Token
  String generateJwtToken() {
    final jwt = JWT({
      'app_key': sdkKey,  // The Zoom SDK Key
      'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,  // Issued at
      'exp': (DateTime.now().millisecondsSinceEpoch ~/ 1000) + 3600,  // Token expires in 1 hour
      'tpc': 'test01',  // Topic or session ID
      'role_type': 1,  // 1 for host, 0 for participant
    });

    // Sign the token with the SDK Secret
    final token = jwt.sign(SecretKey(sdkSecret));
    return token;
  }

  // Initialize the Zoom SDK
  Future<void> initialize() async {
    await _zoomVideoSdk.initSdk(
      InitConfig(
        domain: 'zoom.us',
        enableLog: true,
      ),
    );
  }

  // Join a Zoom session/meeting
  Future<void> joinMeeting({required String sessionName, required String sessionPassword}) async {
    final token = generateJwtToken();  // Generate token dynamically

    Map<String, bool> SDKaudioOptions = {
      "connect": true,
      "mute": true
    };
    Map<String, bool> SDKvideoOptions = {
      "localVideoOn": true,
    };

    JoinSessionConfig joinSession = JoinSessionConfig(
      sessionName: sessionName,
      sessionPassword: sessionPassword,
      token: token,  // Use generated token
      userName: "displayName",
      audioOptions: SDKaudioOptions,
      videoOptions: SDKvideoOptions,
    );

    await _zoomVideoSdk.joinSession(joinSession);
  }

  // Start a Zoom meeting/session
  Future<void> startMeeting({required String sessionName}) async {
    final token = generateJwtToken();  // Generate token dynamically

    Map<String, bool> SDKaudioOptions = {
      "connect": true,
      "mute": false
    };
    Map<String, bool> SDKvideoOptions = {
      "localVideoOn": true,
    };

    JoinSessionConfig startSession = JoinSessionConfig(
      sessionName: sessionName,
      token: token,  // Use generated token
      userName: "displayName",
      audioOptions: SDKaudioOptions,
      videoOptions: SDKvideoOptions,
    );

    await _zoomVideoSdk.joinSession(startSession);
  }
}
