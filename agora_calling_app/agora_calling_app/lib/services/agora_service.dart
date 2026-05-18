import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/call_model.dart';

class CallService {

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> startCall(
      CallModel call) async {

    await _firestore
        .collection('calls')
        .doc(call.channelId)
        .set(call.toMap());
  }

  Stream<DocumentSnapshot> listenCall(
      String channelId) {

    return _firestore
        .collection('calls')
        .doc(channelId)
        .snapshots();
  }

  Future<void> updateCallStatus({

    required String channelId,
    required String status,

  }) async {

    await _firestore
        .collection('calls')
        .doc(channelId)
        .update({

      'status': status,
    });
  }

  Future<void> endCall(
      String channelId) async {

    await _firestore
        .collection('calls')
        .doc(channelId)
        .delete();
  }
}