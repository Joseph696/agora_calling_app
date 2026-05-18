import 'package:agora_calling_app/services/notification_service.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CallProvider extends ChangeNotifier {
  RtcEngine? engine;
  bool muted = false;
  bool videoDisabled = false;
  int? remoteUid;
  int localUid = 0;
  bool joined = false;
  bool isInitializing = false;
  bool speakerOn = true;


void toggleSpeaker() {
  speakerOn = !speakerOn;
  engine?.setDefaultAudioRouteToSpeakerphone(speakerOn);
  notifyListeners();
}

 Future<void> initializeAgora({
  required String appId,
  required String channelId,
  bool isVideo = true, // ✅ ADD
}) async {
  try {
    isInitializing = true;
    notifyListeners();

    engine = createAgoraRtcEngine();
    await engine!.initialize(RtcEngineContext(appId: appId));

    engine!.registerEventHandler(RtcEngineEventHandler(
      onJoinChannelSuccess: (connection, elapsed) {
        print('✅ JOINED CHANNEL SUCCESS uid=${connection.localUid}');
        joined = true;
        notifyListeners();
      },
      onUserJoined: (connection, uid, elapsed) {
        print('✅ REMOTE USER JOINED: $uid');
        remoteUid = uid;
        notifyListeners();
      },
      onUserOffline: (connection, uid, reason) {
        print('🔴 REMOTE USER LEFT: $uid');
        remoteUid = null;
        notifyListeners();
      },
      onError: (err, msg) {
        print('❌ AGORA ERROR: $err — $msg');
      },
      onAudioVolumeIndication: (connection, speakers, speakerNumber, totalVolume) {
        print('AUDIO VOLUME: $totalVolume');
      },
    ));

    await engine!.enableAudio();
    await engine!.enableLocalAudio(true);
    await engine!.setDefaultAudioRouteToSpeakerphone(true);
    await engine!.enableAudioVolumeIndication(
      interval: 200,
      smooth: 3,
      reportVad: true,
    );

    // ✅ Only enable video for video calls
    if (isVideo) {
      await engine!.enableVideo();
    } else {
      await engine!.disableVideo(); // ✅ disable for audio call
    }

    String firebaseUid = FirebaseAuth.instance.currentUser!.uid;
    localUid = firebaseUid.codeUnits.fold(0, (p, e) => p + e) % 999998 + 1;

    await engine!.joinChannel(
      token: '',
      channelId: channelId,
      uid: localUid,
      options: ChannelMediaOptions(
        channelProfile: ChannelProfileType.channelProfileCommunication,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
        publishCameraTrack: isVideo,       // ✅ only publish camera for video
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: isVideo,       // ✅ only subscribe video for video
        enableAudioRecordingOrPlayout: true,
      ),
    );

    if (isVideo) await engine!.startPreview(); // ✅ only preview for video

  } catch (e) {
    debugPrint('Agora Error: $e');
  } finally {
    isInitializing = false;
    notifyListeners();
  }
}

  void toggleMute() {
    muted = !muted;
    engine?.muteLocalAudioStream(muted);
    notifyListeners();
  }

  void toggleVideo() {
    videoDisabled = !videoDisabled;
    engine?.muteLocalVideoStream(videoDisabled);
    notifyListeners();
  }

  Future<void> switchCamera() async {
    await engine?.switchCamera();
  }

  Future<void> leaveCall() async {
    try {
      await engine?.leaveChannel();
      await engine?.release();
    } catch (_) {}
    joined = false;
    remoteUid = null;
    notifyListeners();
  }

Future<String> startAudioCall({
  required String callerId,
  required String callerName,
  required String receiverId,
}) async {
  String channelId = DateTime.now().millisecondsSinceEpoch.toString();

  await FirebaseFirestore.instance.collection('calls').doc(channelId).set({
    'callerId': callerId,
    'callerName': callerName,
    'receiverId': receiverId,
    'channelId': channelId,
    'isVideo': false,
    'status': 'ringing',
  });

  // ✅ Get receiver FCM token and send notification
  final receiverDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(receiverId)
      .get();

  final fcmToken = receiverDoc.data()?['fcmToken'];

  if (fcmToken != null) {
    await NotificationService.sendCallNotification(
      receiverFcmToken: fcmToken,
      callerName: callerName,
      channelId: channelId,
      callId: channelId,
    );
  }

  notifyListeners();
  return channelId;
}

Future<String> startVideoCall({
  required String callerId,
  required String callerName,
  required String receiverId,
}) async {
  String channelId = DateTime.now().millisecondsSinceEpoch.toString();

  await FirebaseFirestore.instance.collection('calls').doc(channelId).set({
    'callerId': callerId,
    'callerName': callerName,
    'receiverId': receiverId,
    'channelId': channelId,
    'isVideo': true,
    'status': 'ringing',
  });

  // ✅ ADD THIS — get receiver token and send notification
  final receiverDoc = await FirebaseFirestore.instance
      .collection('users')
      .doc(receiverId)
      .get();

  final fcmToken = receiverDoc.data()?['fcmToken'];

  if (fcmToken != null) {
    await NotificationService.sendCallNotification(
      receiverFcmToken: fcmToken,
      callerName: callerName,
      channelId: channelId,
      callId: channelId,
    );
  }

  notifyListeners();
  return channelId;
}

  Future<void> updateCallStatus({
    required String channelId,
    required String status,
  }) async {
    await FirebaseFirestore.instance
        .collection('calls')
        .doc(channelId)
        .update({'status': status});
  }
}