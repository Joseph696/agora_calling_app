import 'package:agora_calling_app/providers/call_provider.dart';
import 'package:agora_calling_app/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class CallScreen extends StatefulWidget {
  final String channelId;
  final bool isReceiver;
  final bool isVideo;
  final String receiverName; // ✅ ADD

  const CallScreen({
    super.key,
    required this.channelId,
    this.isReceiver = false,
    this.isVideo = true,
    this.receiverName = '', // ✅ ADD
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  bool _agoraStarted = false;

  @override
  void initState() {
    super.initState();

    if (widget.isReceiver) {
      initialize();
    } else {
      listenForConnected();
    }

    listenCallStatus();
  }

  void listenForConnected() {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.channelId)
        .snapshots()
        .listen((snapshot) {
      if (!snapshot.exists) return;
      final status = snapshot.data()?['status'];
      if (status == 'connected' && !_agoraStarted) {
        _agoraStarted = true;
        initialize();
      }
    });
  }

Future<void> initialize() async {
  await [
    Permission.microphone,
    if (widget.isVideo) Permission.camera, // ✅ only ask camera for video
  ].request();

  if (mounted) {
    await context.read<CallProvider>().initializeAgora(
      appId: AppConstants.agoraAppId,
      channelId: widget.channelId,
      isVideo: widget.isVideo, // ✅ pass isVideo
    );
  }
}

  void listenCallStatus() {
    FirebaseFirestore.instance
        .collection('calls')
        .doc(widget.channelId)
        .snapshots()
        .listen((snapshot) async {
      if (!snapshot.exists) return;
      final data = snapshot.data();
      if (data == null) return;

      String status = data['status'];

      if (status == 'ended' || status == 'rejected') {
        final provider = context.read<CallProvider>();
        await provider.leaveCall();

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    });
  }

  // ✅ Calling screen — shown before receiver accepts
Widget _buildCallingScreen() {
  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: SizedBox(
        width: double.infinity, // ✅ full width
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center, // ✅ center
          children: [
            const CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              widget.receiverName.isEmpty ? 'Unknown' : widget.receiverName,
              textAlign: TextAlign.center, // ✅ center text
              style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Calling...',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 18),
            ),
            const SizedBox(height: 60),
            CircleAvatar(
              radius: 35,
              backgroundColor: Colors.red,
              child: IconButton(
                onPressed: () async {
                  final provider = context.read<CallProvider>();
                  await provider.updateCallStatus(
                    channelId: widget.channelId,
                    status: 'ended',
                  );
                  await provider.leaveCall();
                  if (context.mounted) {
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  }
                },
                icon: const Icon(Icons.call_end, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

@override
Widget build(BuildContext context) {
  final provider = Provider.of<CallProvider>(context);

  if (!widget.isReceiver && (provider.engine == null || provider.isInitializing)) {
    return _buildCallingScreen();
  }

  if (widget.isReceiver && (provider.engine == null || provider.isInitializing)) {
    return const Scaffold(
      backgroundColor: Colors.black,
      body: Center(child: CircularProgressIndicator(color: Colors.white)),
    );
  }

  // ✅ Audio call UI
  if (!widget.isVideo) {
    return _buildAudioCallScreen(provider);
  }

  // ✅ Video call UI — same as before
  return _buildVideoCallScreen(provider);
}

// ✅ Audio call screen
Widget _buildAudioCallScreen(provider) {
  return Scaffold(
    backgroundColor: const Color(0xFF0F172A),
    body: SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 60,
            backgroundColor: Color(0xFF1E293B),
            child: Icon(Icons.person, size: 60, color: Colors.white54),
          ),
          const SizedBox(height: 24),
          Text(
            widget.receiverName.isEmpty ? 'Unknown' : widget.receiverName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            provider.remoteUid != null ? 'On call' : 'Connecting...',
            style: const TextStyle(color: Colors.white54, fontSize: 16),
          ),
          const SizedBox(height: 60),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Mute button
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white12,
                child: IconButton(
                  onPressed: () => provider.toggleMute(),
                  icon: Icon(
                    provider.muted ? Icons.mic_off : Icons.mic,
                    color: Colors.white,
                  ),
                ),
              ),
              // End call button
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.red,
                child: IconButton(
                  onPressed: () async {
                    await provider.updateCallStatus(
                      channelId: widget.channelId,
                      status: 'ended',
                    );
                    await provider.leaveCall();
                    if (context.mounted) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    }
                  },
                  icon: const Icon(Icons.call_end, color: Colors.white),
                ),
              ),
              // Speaker button
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.white12,
                child: IconButton(
                  onPressed: () {
                    provider.toggleSpeaker();
                  },
                  icon: Icon(
                    provider.speakerOn ? Icons.volume_up : Icons.volume_off,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ✅ Video call screen
Widget _buildVideoCallScreen(provider) {
  return Scaffold(
    backgroundColor: Colors.black,
    body: SafeArea(
      child: Stack(
        children: [
          Center(
            child: provider.remoteUid != null
                ? AgoraVideoView(
                    controller: VideoViewController.remote(
                      rtcEngine: provider.engine!,
                      canvas: VideoCanvas(uid: provider.remoteUid),
                      connection: RtcConnection(channelId: widget.channelId),
                    ),
                  )
                : const Text(
                    'Waiting for user...',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: SizedBox(
              width: 120,
              height: 170,
              child: AgoraVideoView(
                controller: VideoViewController(
                  rtcEngine: provider.engine!,
                  canvas: const VideoCanvas(uid: 0),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      onPressed: () => provider.toggleMute(),
                      icon: Icon(
                        provider.muted ? Icons.mic_off : Icons.mic,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      onPressed: () => provider.switchCamera(),
                      icon: const Icon(Icons.cameraswitch, color: Colors.white),
                    ),
                  ),
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.red,
                    child: IconButton(
                      onPressed: () async {
                        await provider.updateCallStatus(
                          channelId: widget.channelId,
                          status: 'ended',
                        );
                        await provider.leaveCall();
                        if (context.mounted) {
                          Navigator.of(context)
                              .popUntil((route) => route.isFirst);
                        }
                      },
                      icon: const Icon(Icons.call_end, color: Colors.white),
                    ),
                  ),
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: IconButton(
                      onPressed: () => provider.toggleVideo(),
                      icon: Icon(
                        provider.videoDisabled
                            ? Icons.videocam_off
                            : Icons.videocam,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    ),
  );
}
}