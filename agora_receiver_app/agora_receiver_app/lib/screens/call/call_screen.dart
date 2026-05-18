// import 'package:agora_calling_app/utils/constants.dart';
// import 'package:agora_rtc_engine/agora_rtc_engine.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:permission_handler/permission_handler.dart';

// class CallScreen extends StatefulWidget {
//   final String channelId;
//   final bool isReceiver;  // true = receiver app, false = caller app

//   const CallScreen({
//     super.key,
//     required this.channelId,
//     this.isReceiver = false,
//   });

//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }

// class _CallScreenState extends State<CallScreen> {
//   RtcEngine? _engine;
//   int? _remoteUid;
//   bool _joined = false;

//   static const String _appId = AppConstants.agoraAppId; // ← paste your App ID

//   // Makes a stable number from Firebase UID
//   int _makeUid(String firebaseUid) {
//     int hash = firebaseUid.codeUnits.fold(0, (p, e) => p + e);
//     return hash.abs() % 999998 + 1;
//   }

//   @override
//   void initState() {
//     super.initState();

//     if (widget.isReceiver) {
//       // Receiver joins immediately
//       _initAgora();
//     } else {
//       // Caller waits for status == connected, then joins
//       _waitThenJoin();
//     }
//   }

//   // Only used in Caller App
//   void _waitThenJoin() {
//     FirebaseFirestore.instance
//         .collection('calls')
//         .doc(widget.channelId)
//         .snapshots()
//         .listen((snap) {
//       if (snap.data()?['status'] == 'connected' && !_joined) {
//         _joined = true;
//         _initAgora();
//       }
//     });
//   }

//   Future<void> _initAgora() async {
//     // Step A: Ask for permissions
//     await [Permission.camera, Permission.microphone].request();

//     // Step B: Get local uid from Firebase UID
//     final firebaseUid = FirebaseAuth.instance.currentUser!.uid;
//     final localUid = _makeUid(firebaseUid);

//     // Step C: Create engine
//     _engine = createAgoraRtcEngine();
//     await _engine!.initialize(const RtcEngineContext(
//       appId: _appId,
//       channelProfile: ChannelProfileType.channelProfileCommunication,
//     ));

//     // Step D: Register events BEFORE joining
//     _engine!.registerEventHandler(
//       RtcEngineEventHandler(
//         onJoinChannelSuccess: (connection, elapsed) {
//           debugPrint('✅ Joined! uid=${connection.localUid}');
//           setState(() {});
//         },
//         onUserJoined: (connection, remoteUid, elapsed) {
//           debugPrint('✅ Remote user joined: $remoteUid');
//           setState(() {
//             _remoteUid = remoteUid;
//           });
//         },
//         onUserOffline: (connection, remoteUid, reason) {
//           debugPrint('🔴 Remote user left');
//           setState(() {
//             _remoteUid = null;
//           });
//         },
//         onError: (err, msg) {
//           debugPrint('❌ Agora error: $err — $msg');
//         },
//       ),
//     );

//     // Step E: Enable video and audio
//     await _engine!.enableVideo();
//     await _engine!.enableAudio();

//     // Step F: Join channel
//     await _engine!.joinChannel(
//       token: '',
//       channelId: widget.channelId,
//       uid: localUid,
//       options: const ChannelMediaOptions(
//         channelProfile: ChannelProfileType.channelProfileCommunication,
//         clientRoleType: ClientRoleType.clientRoleBroadcaster,
//         publishCameraTrack: true,
//         publishMicrophoneTrack: true,
//         autoSubscribeAudio: true,
//         autoSubscribeVideo: true,
//       ),
//     );

//     // Step G: Start preview AFTER joining
//     await _engine!.startPreview();

//     setState(() {});
//   }

//   Future<void> _endCall() async {
//     await FirebaseFirestore.instance
//         .collection('calls')
//         .doc(widget.channelId)
//         .update({'status': 'ended'});

//     await _engine?.leaveChannel();
//     await _engine?.release();
//     _engine = null;

//     if (mounted) Navigator.pop(context);
//   }

//   @override
//   void dispose() {
//     _engine?.leaveChannel();
//     _engine?.release();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             // Remote video (full screen)
//             _remoteUid != null
//                 ? AgoraVideoView(
//                     controller: VideoViewController.remote(
//                       rtcEngine: _engine!,
//                       canvas: VideoCanvas(uid: _remoteUid),
//                       connection: RtcConnection(channelId: widget.channelId),
//                     ),
//                   )
//                 : const Center(
//                     child: Text(
//                       'Waiting for other user...',
//                       style: TextStyle(color: Colors.white, fontSize: 18),
//                     ),
//                   ),

//             // Local video (small, top-right corner)
//             if (_engine != null)
//               Positioned(
//                 top: 16,
//                 right: 16,
//                 width: 120,
//                 height: 160,
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(8),
//                   child: AgoraVideoView(
//                     controller: VideoViewController(
//                       rtcEngine: _engine!,
//                       canvas: const VideoCanvas(uid: 0), // 0 = local user
//                     ),
//                   ),
//                 ),
//               ),

//             // End call button (bottom center)
//             Positioned(
//               bottom: 40,
//               left: 0,
//               right: 0,
//               child: Center(
//                 child: CircleAvatar(
//                   radius: 35,
//                   backgroundColor: Colors.red,
//                   child: IconButton(
//                     onPressed: _endCall,
//                     icon: const Icon(Icons.call_end, color: Colors.white),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:async';

import 'package:agora_calling_app/providers/call_provider.dart';
import 'package:agora_calling_app/utils/constants.dart';

import 'package:agora_rtc_engine/agora_rtc_engine.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

import 'package:permission_handler/permission_handler.dart';

import 'package:provider/provider.dart';

class CallScreen extends StatefulWidget {

  final String channelId;

  final bool isReceiver;

  final bool isVideo;

  final String receiverName;

  const CallScreen({

    super.key,

    required this.channelId,

    required this.receiverName,

    required this.isVideo,

    this.isReceiver = false,
  });

  @override
  State<CallScreen> createState() =>
      _CallScreenState();
}

class _CallScreenState
    extends State<CallScreen> {

  Timer? timer;

  int seconds = 0;

  @override
  void initState() {

    super.initState();

    initializeCall();

    listenCallStatus();
  }

  Future<void> initializeCall() async {

    if (widget.isVideo) {

      await [
        Permission.camera,
        Permission.microphone,
      ].request();

    } else {

      await [
        Permission.microphone,
      ].request();
    }

    if (!mounted) return;

    final provider =
        context.read<CallProvider>();

    await provider.initializeAgora(

      appId:
          AppConstants.agoraAppId,

      channelId:
          widget.channelId,

      isVideo:
          widget.isVideo,
    );
  }

  void startTimer() {

    timer?.cancel();

    timer = Timer.periodic(

      const Duration(
        seconds: 1,
      ),

      (timer) {

        if (!mounted) return;

        setState(() {

          seconds++;
        });
      },
    );
  }

  String formatDuration() {

    final minutes =
        (seconds ~/ 60)

            .toString()

            .padLeft(2, '0');

    final remainingSeconds =
        (seconds % 60)

            .toString()

            .padLeft(2, '0');

    return '$minutes:$remainingSeconds';
  }

  void listenCallStatus() {

    FirebaseFirestore.instance

        .collection('calls')

        .doc(widget.channelId)

        .snapshots()

        .listen((snapshot) async {

      if (!snapshot.exists) {
        return;
      }

      final data =
          snapshot.data();

      if (data == null) {
        return;
      }

      final status =
          data['status'];

      if (status == 'ended' ||
          status == 'rejected') {

        if (!mounted) return;

        final provider =
            context.read<
                CallProvider>();

        await provider.leaveCall();

        if (mounted) {

          Navigator.popUntil(

            context,

            (route) =>
                route.isFirst,
          );
        }
      }
    });
  }

  Future<void> endCall() async {

    await FirebaseFirestore
        .instance
        .collection('calls')
        .doc(widget.channelId)
        .update({

      'status': 'ended',

      'endedAt':
          FieldValue.serverTimestamp(),

      'duration':
          seconds,
    });

    if (!mounted) return;

    final provider =
        context.read<
            CallProvider>();

    await provider.leaveCall();

    if (mounted) {

      Navigator.popUntil(

        context,

        (route) =>
            route.isFirst,
      );
    }
  }

  @override
  void dispose() {

    timer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Consumer<CallProvider>(

      builder:
          (context, provider, child) {

        if (provider.remoteUid !=
                null &&
            timer == null) {

          startTimer();
        }

        return Scaffold(

          backgroundColor:
              Colors.black,

          body: SafeArea(

            child: Stack(

              children: [

                if (widget.isVideo)

                  buildVideoCallUI(
                    provider,
                  )

                else

                  buildAudioCallUI(
                    provider,
                  ),

                Positioned(

                  top: 40,

                  left: 0,

                  right: 0,

                  child: Column(

                    children: [

                      Text(

                        widget
                            .receiverName,

                        style:
                            const TextStyle(

                          color:
                              Colors.white,

                          fontSize:
                              26,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(
                        height: 8,
                      ),

                      Text(

                        provider.remoteUid !=
                                null

                            ? formatDuration()

                            : 'Connecting...',

                        style:
                            TextStyle(

                          color:
                              Colors.white
                                  .withOpacity(
                            0.8,
                          ),

                          fontSize:
                              16,
                        ),
                      ),
                    ],
                  ),
                ),

                Positioned(

                  bottom: 40,

                  left: 0,

                  right: 0,

                  child: Row(

                    mainAxisAlignment:
                        MainAxisAlignment
                            .spaceEvenly,

                    children: [

                      buildControlButton(

                        icon:
                            provider.muted

                                ? Icons
                                    .mic_off

                                : Icons
                                    .mic,

                        onTap:
                            provider
                                .toggleMute,
                      ),

                      if (widget.isVideo)

                        buildControlButton(

                          icon:
                              provider
                                      .videoDisabled

                                  ? Icons
                                      .videocam_off

                                  : Icons
                                      .videocam,

                          onTap:
                              provider
                                  .toggleVideo,
                        ),

                      CircleAvatar(

                        radius: 32,

                        backgroundColor:
                            Colors.red,

                        child:
                            IconButton(

                          onPressed:
                              endCall,

                          icon:
                              const Icon(

                            Icons.call_end,

                            color:
                                Colors.white,
                          ),
                        ),
                      ),

                      if (widget.isVideo)

                        buildControlButton(

                          icon:
                              Icons
                                  .cameraswitch,

                          onTap:
                              provider
                                  .switchCamera,
                        ),

                      buildControlButton(

                        icon:
                            Icons
                                .volume_up,

                        onTap: () {

                          provider.engine
                              ?.setEnableSpeakerphone(
                            true,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget buildVideoCallUI(
    CallProvider provider,
  ) {

    return Stack(

      children: [

        provider.remoteUid != null

            ? AgoraVideoView(

                controller:
                    VideoViewController.remote(

                  rtcEngine:
                      provider.engine!,

                  canvas:
                      VideoCanvas(

                    uid:
                        provider
                            .remoteUid,
                  ),

                  connection:
                      RtcConnection(

                    channelId:
                        widget.channelId,
                  ),
                ),
              )

            : const Center(

                child: Text(

                  'Waiting for user...',

                  style: TextStyle(

                    color:
                        Colors.white,

                    fontSize: 18,
                  ),
                ),
              ),

        Positioned(

          top: 20,

          right: 20,

          child: Container(

            width: 120,

            height: 170,

            decoration:
                BoxDecoration(

              borderRadius:
                  BorderRadius.circular(
                18,
              ),
            ),

            clipBehavior:
                Clip.hardEdge,

            child: AgoraVideoView(

              controller:
                  VideoViewController(

                rtcEngine:
                    provider.engine!,

                canvas:
                    VideoCanvas(

                  uid:
                      provider
                          .localUid,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildAudioCallUI(
    CallProvider provider,
  ) {

    return Center(

      child: Column(

        mainAxisAlignment:
            MainAxisAlignment.center,

        children: [

          CircleAvatar(

            radius: 70,

            backgroundColor:
                const Color(
              0xff4F46E5,
            ),

            child: Text(

              widget.receiverName[0]
                  .toUpperCase(),

              style:
                  const TextStyle(

                color:
                    Colors.white,

                fontSize: 48,

                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(
            height: 30,
          ),

          Text(

            provider.remoteUid !=
                    null

                ? 'Audio Call Connected'

                : 'Waiting for receiver...',

            style: TextStyle(

              color:
                  Colors.white
                      .withOpacity(
                0.8,
              ),

              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildControlButton({

    required IconData icon,

    required VoidCallback onTap,

  }) {

    return CircleAvatar(

      radius: 28,

      backgroundColor:
          Colors.white24,

      child: IconButton(

        onPressed: onTap,

        icon: Icon(

          icon,

          color: Colors.white,
        ),
      ),
    );
  }
}