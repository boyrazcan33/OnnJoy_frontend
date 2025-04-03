import 'dart:async';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoCallPage extends StatefulWidget {
  final String channelName;
  final String token;
  final int uid;

  const VideoCallPage({
    Key? key,
    required this.channelName,
    required this.token,
    required this.uid,
  }) : super(key: key);

  @override
  State<VideoCallPage> createState() => _VideoCallPageState();
}

class _VideoCallPageState extends State<VideoCallPage> {
  bool _joined = false;
  bool _muted = false;
  bool _remoteVideoVisible = false;
  bool _doubleTapToExit = false;

  late RtcEngine _engine;

  @override
  void initState() {
    super.initState();
    _initAgora();
  }

  Future<void> _initAgora() async {
    await [Permission.microphone, Permission.camera].request();

    _engine = createAgoraRtcEngine();
    await _engine.initialize(
      RtcEngineContext(
        appId: 'YOUR_AGORA_APP_ID', // Replace with actual App ID
      ),
    );

    _engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          setState(() => _joined = true);
        },
        onUserJoined: (RtcConnection connection, int remoteUid, int elapsed) {
          setState(() => _remoteVideoVisible = true);
        },
        onUserOffline: (RtcConnection connection, int remoteUid, UserOfflineReasonType reason) {
          setState(() => _remoteVideoVisible = false);
        },
      ),
    );

    await _engine.enableVideo();
    await _engine.muteLocalAudioStream(false);
    await _engine.muteLocalVideoStream(true); // User is unseen
    await _engine.joinChannel(
      token: widget.token,
      channelId: widget.channelName,
      uid: widget.uid,
      options: const ChannelMediaOptions(),
    );
  }

  void _toggleMute() {
    setState(() => _muted = !_muted);
    _engine.muteLocalAudioStream(_muted);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_muted ? 'Mic muted' : 'Mic unmuted'),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _toggleMask() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Voice masking toggled")),
    );
  }

  void _handleExit() {
    if (_doubleTapToExit) {
      _engine.leaveChannel();
      Navigator.pushReplacementNamed(context, '/notifications');
    } else {
      setState(() => _doubleTapToExit = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tap again to leave session')),
      );
      Timer(const Duration(seconds: 3), () {
        setState(() => _doubleTapToExit = false);
      });
    }
  }

  @override
  void dispose() {
    _engine.leaveChannel();
    _engine.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/icons/logo.png', height: 40),
      ),
      body: Stack(
        children: [
          Center(
            child: _joined && _remoteVideoVisible
                ? const Text("Therapist's video stream will appear here.")
                : const Text("Waiting for therapist to join..."),
          ),
          Positioned(
            bottom: 32,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: Image.asset(
                    'assets/icons/mic.png',
                    color: _muted ? Colors.red : Colors.black,
                    height: 30,
                  ),
                  onPressed: _toggleMute,
                ),
                IconButton(
                  icon: Image.asset('assets/icons/video-call.png', height: 30),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Therapist controls the camera')),
                    );
                  },
                ),
                IconButton(
                  icon: Image.asset('assets/icons/voice_mask.png', height: 30),
                  onPressed: _toggleMask,
                ),
                IconButton(
                  icon: Image.asset('assets/icons/phone-call.png', height: 30),
                  onPressed: _handleExit,
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 12,
            right: 20,
            child: Text(
              'Username123', // Optionally replace with actual user from provider
              style: const TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
