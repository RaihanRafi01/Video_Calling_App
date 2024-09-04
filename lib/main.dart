import 'package:flutter/material.dart';
import 'package:test_v1/services/zoom_api.dart';
import 'package:test_v1/services/zoom_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zoom Video App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: VideoCallScreen(),
    );
  }
}

class VideoCallScreen extends StatefulWidget {
  @override
  _VideoCallScreenState createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final ZoomService _zoomService = ZoomService();
  final ZoomApiService _zoomApiService = ZoomApiService();
  final TextEditingController _sessionNameController = TextEditingController();
  final TextEditingController _sessionPasswordController = TextEditingController();
  final TextEditingController _meetingTopicController = TextEditingController();
  final TextEditingController _meetingStartTimeController = TextEditingController();
  bool _isInitialized = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeZoomSDK();
  }

  Future<void> _initializeZoomSDK() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _zoomService.initialize();
      setState(() {
        _isInitialized = true;
      });
    } catch (e) {
      print('Error initializing Zoom SDK: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }


  Future<void> _joinMeeting() async {
    if (_isInitialized) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _zoomService.joinMeeting(
          sessionName: _sessionNameController.text.trim(),
          sessionPassword: _sessionPasswordController.text.trim(),
        );
      } catch (e) {
        print('Error joining meeting: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Zoom SDK not initialized');
    }
  }

  Future<void> _startMeeting() async {
    if (_isInitialized) {
      setState(() {
        _isLoading = true;
      });
      try {
        await _zoomService.startMeeting(
          sessionName: _sessionNameController.text.trim(),
        );
      } catch (e) {
        print('Error starting meeting: $e');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('Zoom SDK not initialized');
    }
  }

  Future<void> _scheduleMeeting() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _zoomApiService.createMeeting(
        _meetingTopicController.text.trim(),
        _meetingStartTimeController.text.trim(),
      );
    } catch (e) {
      print('Error scheduling meeting: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchMeetings() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await _zoomApiService.getScheduledMeetings();
    } catch (e) {
      print('Error fetching meetings: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Zoom Video Call'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _sessionNameController,
                decoration: InputDecoration(
                  labelText: 'Session Name',
                ),
              ),
              TextField(
                controller: _sessionPasswordController,
                decoration: InputDecoration(
                  labelText: 'Session Password',
                ),
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _joinMeeting,
                child: Text('Join Meeting'),
              ),
              ElevatedButton(
                onPressed: _startMeeting,
                child: Text('Start Meeting'),
              ),
              Divider(),
              TextField(
                controller: _meetingTopicController,
                decoration: InputDecoration(
                  labelText: 'Meeting Topic',
                ),
              ),
              TextField(
                controller: _meetingStartTimeController,
                decoration: InputDecoration(
                  labelText: 'Start Time (ISO 8601 Format)',
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _scheduleMeeting,
                child: Text('Schedule Meeting'),
              ),
              ElevatedButton(
                onPressed: _fetchMeetings,
                child: Text('Fetch Scheduled Meetings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  @override
  void dispose() {
    _sessionNameController.dispose();
    _sessionPasswordController.dispose();
    _meetingTopicController.dispose();
    _meetingStartTimeController.dispose();
    super.dispose();
  }
}