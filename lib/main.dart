import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter/services.dart';

import 'services/zoom_api.dart';
import 'services/zoom_service.dart';

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
  static const platform = MethodChannel('com.example.video_calling_app/zoom');

  final ZoomService _zoomService = ZoomService();
  final ZoomApiService _zoomApiService = ZoomApiService('Apjd7ZV4Rz-Lkk2y9NdTKg', 'x6M85Mi4Sl8Ae9ZpPlzcvX1TxF4TcOBnnR1d');
  final TextEditingController _sessionNameController = TextEditingController();
  final TextEditingController _sessionPasswordController = TextEditingController();
  final TextEditingController _meetingTopicController = TextEditingController();
  DateTime? _meetingStartTime;
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
          _sessionNameController.text.trim(),
          _sessionPasswordController.text.trim(),
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
          _sessionNameController.text.trim(),
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
      if (_meetingStartTime != null) {
        await _zoomApiService.createMeeting(
          _meetingTopicController.text.trim(),
          _meetingStartTime!.toIso8601String(),
        );
      } else {
        print('Please select a meeting start time.');
      }
    } catch (e) {
      print('Error scheduling meeting: $e');
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
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  DatePicker.showDateTimePicker(context, onConfirm: (date) {
                    setState(() => _meetingStartTime = date);
                  });
                },
                child: Text(
                  _meetingStartTime == null ? 'Pick Start Time' : _meetingStartTime.toString(),
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _scheduleMeeting,
                child: Text('Schedule Meeting'),
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
    super.dispose();
  }
}
