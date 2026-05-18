// import 'package:agora_calling_app/screens/auth/login_screen.dart';
// import 'package:agora_calling_app/screens/call/incoming_call_screen.dart';
// import 'package:agora_calling_app/screens/call_history_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class ReceiverHomeScreen extends StatefulWidget {
//   const ReceiverHomeScreen({super.key});

//   @override
//   State<ReceiverHomeScreen> createState() => _ReceiverHomeScreenState();
// }

// class _ReceiverHomeScreenState extends State<ReceiverHomeScreen> {
//   bool isShowingCallScreen = false;

//   @override
//   void initState() {
//     super.initState();
//     listenIncomingCalls();
//   }

//   void listenIncomingCalls() {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     FirebaseFirestore.instance
//         .collection('calls')
//         .where('receiverId', isEqualTo: user.uid)
//         .snapshots()
//         .listen((snapshot) {
//       if (!mounted) return;
//       if (snapshot.docs.isEmpty) return;

//       for (var call in snapshot.docs) {
//         final data = call.data();
//         final status = data['status'];

//         if (status == 'ringing' && !isShowingCallScreen) {
//           isShowingCallScreen = true;

//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (_) => IncomingCallScreen(
//                 callerName: data['callerName'],
//                 channelId: data['channelId'],
//                 callId: call.id,
//               ),
//             ),
//           ).then((_) {
//             isShowingCallScreen = false;
//           });

//           break;
//         }
//       }
//     });
//   }

//   // ✅ Logout function
//   Future<void> _logout() async {
//     await FirebaseAuth.instance.signOut();

//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('isLogin', false);

//     if (mounted) {
//       Navigator.pushAndRemoveUntil(
//         context,
//         MaterialPageRoute(builder: (_) => const LoginScreen()),
//         (route) => false,
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final user = FirebaseAuth.instance.currentUser;

//     return Scaffold(
//       backgroundColor: const Color(0xFF0F172A),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF1E293B),
//         title: const Text(
//           'Receiver App',
//           style: TextStyle(color: Colors.white),
//         ),
//         actions: [
//           // ✅ History button
//           IconButton(
//             onPressed: () {
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => const CallHistoryScreen(),
//                 ),
//               );
//             },
//             icon: const Icon(Icons.history, color: Colors.white),
//           ),

//           // ✅ Logout button
//           IconButton(
//             onPressed: _logout,
//             icon: const Icon(Icons.logout, color: Colors.white),
//           ),
//         ],
//       ),

//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               height: 120,
//               width: 120,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: const Color(0xFF4F46E5).withOpacity(0.15),
//                 border: Border.all(
//                   color: const Color(0xFF4F46E5).withOpacity(0.4),
//                   width: 2,
//                 ),
//               ),
//               child: const Icon(
//                 Icons.call_rounded,
//                 size: 60,
//                 color: Color(0xFF4F46E5),
//               ),
//             ),

//             const SizedBox(height: 20),

//             Text(
//               user?.email ?? '',
//               style: const TextStyle(
//                 fontSize: 18,
//                 color: Colors.white,
//               ),
//             ),

//             const SizedBox(height: 10),

//             Text(
//               'Waiting for incoming calls...',
//               style: TextStyle(
//                 fontSize: 16,
//                 color: Colors.white.withOpacity(0.5),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:agora_calling_app/screens/auth/login_screen.dart';
import 'package:agora_calling_app/screens/call/incoming_call_screen.dart';
import 'package:agora_calling_app/screens/call_history_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReceiverHomeScreen extends StatefulWidget {
  const ReceiverHomeScreen({super.key});

  @override
  State<ReceiverHomeScreen> createState() => _ReceiverHomeScreenState();
}

class _ReceiverHomeScreenState extends State<ReceiverHomeScreen> {
  bool isShowingCallScreen = false;

  @override
  void initState() {
    super.initState();

    listenIncomingCalls();
  }

  void listenIncomingCalls() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    FirebaseFirestore.instance
        .collection('calls')
        .where('receiverId', isEqualTo: user.uid)
        .snapshots()
        .listen((snapshot) {
          if (!mounted) return;

          if (snapshot.docs.isEmpty) {
            return;
          }

          for (var call in snapshot.docs) {
            final data = call.data();

            final status = data['status'];

            if (status == 'ringing' && !isShowingCallScreen) {
              isShowingCallScreen = true;

              Navigator.push(
                context,

                MaterialPageRoute(
                  builder: (_) => IncomingCallScreen(
                    callerName: data['callerName'],

                    channelId: data['channelId'],

                    callId: call.id,

                    isVideo: data['isVideo'],
                  ),
                ),
              ).then((_) {
                isShowingCallScreen = false;
              });

              break;
            }
          }
        });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool('isLogin', false);

    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,

        MaterialPageRoute(builder: (_) => const LoginScreen()),

        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),

      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),

        title: const Text(
          'Agora Calls Receiver',

          style: TextStyle(color: Colors.white),
        ),

        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,

                MaterialPageRoute(builder: (_) => const CallHistoryScreen()),
              );
            },

            icon: const Icon(Icons.history, color: Colors.white),
          ),

          IconButton(
            onPressed: logout,

            icon: const Icon(Icons.logout, color: Colors.white),
          ),
        ],
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Container(
              height: 120,

              width: 120,

              decoration: BoxDecoration(
                shape: BoxShape.circle,

                color: const Color(0xFF4F46E5).withOpacity(0.15),

                border: Border.all(
                  color: const Color(0xFF4F46E5).withOpacity(0.4),

                  width: 2,
                ),
              ),

              child: const Icon(
                Icons.call_rounded,

                size: 60,

                color: Color(0xFF4F46E5),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              user?.email ?? '',

              style: const TextStyle(fontSize: 18, color: Colors.white),
            ),

            const SizedBox(height: 10),

            Text(
              'Waiting for incoming calls...',

              style: TextStyle(
                fontSize: 16,

                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
