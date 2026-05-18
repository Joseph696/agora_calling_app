class CallModel {

  final String callerId;
  final String callerName;
  final String receiverId;
  final String channelId;
  final bool isVideo;
  final String status;

  CallModel({

    required this.callerId,
    required this.callerName,
    required this.receiverId,
    required this.channelId,
    required this.isVideo,
    required this.status,
  });

  Map<String, dynamic> toMap() {

    return {

      'callerId': callerId,
      'callerName': callerName,
      'receiverId': receiverId,
      'channelId': channelId,
      'isVideo': isVideo,
      'status': status,
    };
  }

  factory CallModel.fromMap(
      Map<String, dynamic> map) {

    return CallModel(

      callerId: map['callerId'],
      callerName: map['callerName'],
      receiverId: map['receiverId'],
      channelId: map['channelId'],
      isVideo: map['isVideo'],
      status: map['status'],
    );
  }
}