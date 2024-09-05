import 'dart:convert';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:http/http.dart' as http;

class ZoomApiService {
  final String apiKey;
  final String apiSecret;
  final String baseUrl = 'https://api.zoom.us/v2';

  ZoomApiService(this.apiKey, this.apiSecret);

  // Generate JWT Token for Zoom API requests
  String _generateJwtToken() {
    final jwt = JWT(
      {
        'iss': apiKey,
        'exp': DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
      },
    );
    return jwt.sign(SecretKey(apiSecret));
  }

  // Create a Zoom meeting via API
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
        'type': 2,
        'start_time': startTime,
        'duration': 60,
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

  // Retrieve scheduled meetings
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
