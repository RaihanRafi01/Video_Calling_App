import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;

class ZoomApiService {
  final String apiKey = 'YOUR_API_KEY';  // Replace with your Zoom API Key
  final String apiSecret = 'YOUR_API_SECRET';  // Replace with your Zoom API Secret
  final String baseUrl = 'https://api.zoom.us/v2';

  // Method to generate JWT Token for Zoom API requests
  String _generateJwtToken() {
    final jwt = JWT(
      {
        'iss': apiKey,  // Issuer is the API Key
        'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,  // Token expiration (1 hour)
      },
    );

    final token = jwt.sign(SecretKey(apiSecret));  // Sign with the API Secret
    return token;
  }

  // Method to create a Zoom meeting via API
  Future<void> createMeeting(String topic, String startTime) async {
    final url = Uri.parse('$baseUrl/users/me/meetings');
    final token = _generateJwtToken();

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'topic': topic,
        'type': 2,  // 2 represents a scheduled meeting
        'start_time': startTime,
        'duration': 60,  // Meeting duration in minutes
        'timezone': 'UTC',
        'settings': {
          'host_video': true,
          'participant_video': true,
        },
      }),
    );

    if (response.statusCode == 201) {
      print('Meeting created successfully');
    } else {
      print('Failed to create meeting: ${response.body}');
    }
  }

  // Method to retrieve scheduled meetings via API
  Future<void> getScheduledMeetings() async {
    final url = Uri.parse('$baseUrl/users/me/meetings');
    final token = _generateJwtToken();

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final meetings = jsonDecode(response.body)['meetings'];
      print('Scheduled Meetings: $meetings');
    } else {
      print('Failed to fetch meetings: ${response.body}');
    }
  }
}
