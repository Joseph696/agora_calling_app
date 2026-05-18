// import 'package:agora_calling_app/screens/call/call_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';

// class IncomingCallScreen extends StatefulWidget {
//   final String callerName;
//   final String channelId;
//   final String callId;

//   const IncomingCallScreen({
//     super.key,
//     required this.callerName,
//     required this.channelId,
//     required this.callId,
//   });

//   @override
//   State<IncomingCallScreen> createState() => _IncomingCallScreenState();
// }

// class _IncomingCallScreenState extends State<IncomingCallScreen> {

//   @override
//   void initState() {
//     super.initState();
//     _saveFcmToken(); // ✅ Save token when screen opens
//   }

//   // ✅ ADDED: Save FCM token to Firestore
//   Future<void> _saveFcmToken() async {
//     try {
//       // Request permission first
//       await FirebaseMessaging.instance.requestPermission();

//       final token = await FirebaseMessaging.instance.getToken();
//       if (token != null) {
//         final uid = FirebaseAuth.instance.currentUser!.uid;
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(uid)
//             .set({'fcmToken': token}, SetOptions(merge: true));
//         print('✅ FCM Token saved: $token');
//       }
//     } catch (e) {
//       print('FCM token error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const CircleAvatar(
//               radius: 60,
//               child: Icon(Icons.person, size: 60),
//             ),

//             const SizedBox(height: 20),

//             Text(
//               widget.callerName,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),

//             const SizedBox(height: 10),

//             const Text(
//               'Incoming Call',
//               style: TextStyle(color: Colors.white70, fontSize: 18),
//             ),

//             const SizedBox(height: 60),

//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//               children: [

//                 // ❌ Reject button — unchanged
//                 CircleAvatar(
//                   radius: 35,
//                   backgroundColor: Colors.red,
//                   child: IconButton(
//                     onPressed: () async {
//                       await FirebaseFirestore.instance
//                           .collection('calls')
//                           .doc(widget.callId)
//                           .update({'status': 'rejected'});

//                       if (context.mounted) {
//                         Navigator.pop(context);
//                       }
//                     },
//                     icon: const Icon(Icons.call_end, color: Colors.white),
//                   ),
//                 ),

//                 // ✅ Accept button — unchanged
//                 CircleAvatar(
//                   radius: 35,
//                   backgroundColor: Colors.green,
//                   child: IconButton(
//                     onPressed: () async {
//                       await FirebaseFirestore.instance
//                           .collection('calls')
//                           .doc(widget.callId)
//                           .update({'status': 'connected'});

//                       if (context.mounted) {
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => CallScreen(
                              
//                               channelId: widget.channelId,
//                               isReceiver: true,
//                             ),
//                           ),
//                         );
//                       }
//                     },
//                     icon: const Icon(Icons.call, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }/



import 'package:agora_calling_app/screens/call/call_screen.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';

class IncomingCallScreen
    extends StatefulWidget {

  final String callerName;

  final String channelId;

  final String callId;

  final bool isVideo;

  const IncomingCallScreen({

    super.key,

    required this.callerName,

    required this.channelId,

    required this.callId,

    required this.isVideo,
  });

  @override
  State<IncomingCallScreen>
      createState() =>
          _IncomingCallScreenState();
}

class _IncomingCallScreenState
    extends State<IncomingCallScreen> {

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          Colors.black,

      body: SafeArea(

        child: Column(

          mainAxisAlignment:
              MainAxisAlignment.center,

          children: [

            const CircleAvatar(

              radius: 60,

              child: Icon(
                Icons.person,
                size: 60,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Text(

              widget.callerName,

              style:
                  const TextStyle(

                color:
                    Colors.white,

                fontSize: 28,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 10,
            ),

            Text(

              widget.isVideo

                  ? 'Incoming Video Call'

                  : 'Incoming Audio Call',

              style:
                  const TextStyle(

                color:
                    Colors.white70,

                fontSize: 18,
              ),
            ),

            const SizedBox(
              height: 60,
            ),

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceEvenly,

              children: [

                CircleAvatar(

                  radius: 35,

                  backgroundColor:
                      Colors.red,

                  child: IconButton(

                    onPressed:
                        () async {

                      await FirebaseFirestore
                          .instance
                          .collection(
                            'calls',
                          )
                          .doc(
                            widget.callId,
                          )
                          .update({

                        'status':
                            'rejected',
                      });

                      if (context
                          .mounted) {

                        Navigator.pop(
                          context,
                        );
                      }
                    },

                    icon: const Icon(

                      Icons.call_end,

                      color:
                          Colors.white,
                    ),
                  ),
                ),

                CircleAvatar(

                  radius: 35,

                  backgroundColor:
                      Colors.green,

                  child: IconButton(

                    onPressed:
                        () async {

                      await FirebaseFirestore
                          .instance
                          .collection(
                            'calls',
                          )
                          .doc(
                            widget.callId,
                          )
                          .update({

                        'status':
                            'connected',
                      });

                      if (context
                          .mounted) {

                        Navigator.pushReplacement(

                          context,

                          MaterialPageRoute(

                            builder: (_) =>
                                CallScreen(

                              receiverName:
                                  widget
                                      .callerName,

                              channelId:
                                  widget
                                      .channelId,

                              isReceiver:
                                  true,

                              isVideo:
                                  widget
                                      .isVideo,
                            ),
                          ),
                        );
                      }
                    },

                    icon: Icon(

                      widget.isVideo

                          ? Icons
                              .videocam

                          : Icons.call,

                      color:
                          Colors.white,
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
}