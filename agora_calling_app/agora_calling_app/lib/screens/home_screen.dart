import 'package:agora_calling_app/providers/auth_provider.dart';
import 'package:agora_calling_app/providers/call_provider.dart';
import 'package:agora_calling_app/providers/user_provider.dart';
import 'package:agora_calling_app/screens/auth/login_screen.dart';
import 'package:agora_calling_app/screens/call/call_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      context.read<UserProvider>().fetchUsers();
    });

    _saveFcmToken(); // ✅ ADDED
  }

  // ✅ ADDED: Save FCM token for caller
  Future<void> _saveFcmToken() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final uid = FirebaseAuth.instance.currentUser!.uid;
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'fcmToken': token,
        }, SetOptions(merge: true));
        print('✅ Caller FCM Token saved: $token');
      }
    } catch (e) {
      print('FCM token error: $e');
    }
  }

  Stream<DocumentSnapshot<Map<String, dynamic>>> getCurrentUserData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    final provider = Provider.of<UserProvider>(context);

    final users = provider.users
        .where((user) => user.uid != currentUser!.uid)
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xff0F172A),

      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,

        centerTitle: false,

        title: StreamBuilder(
          stream: getCurrentUserData(),

          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Text('Agora');
            }

            final data = snapshot.data!.data();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                const Text(
                  'Welcome Back',

                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),

                const SizedBox(height: 2),

                Text(
                  data?['name'] ?? '',

                  style: const TextStyle(
                    fontSize: 22,

                    fontWeight: FontWeight.bold,

                    color: Colors.white,
                  ),
                ),
              ],
            );
          },
        ),

        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),

            decoration: BoxDecoration(
              color: const Color(0xff1E293B),

              borderRadius: BorderRadius.circular(14),
            ),

            child: IconButton(
              onPressed: () async {
                await context.read<AuthController>().logout();

                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,

                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                }
              },

              icon: const Icon(Icons.logout_rounded, color: Colors.white),
            ),
          ),
        ],
      ),

      body: provider.isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xff10B981)),
            )
          : users.isEmpty
          ? const Center(
              child: Text(
                'No Users Found',

                style: TextStyle(color: Colors.white),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Available Receivers',

                        style: TextStyle(
                          color: Colors.white,

                          fontSize: 18,

                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        'Start secure audio or video calls with available users',

                        style: TextStyle(
                          color: Colors.white.withOpacity(0.65),

                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(18),

                    itemCount: users.length,

                    itemBuilder: (context, index) {
                      final user = users[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 18),

                        padding: const EdgeInsets.all(16),

                        decoration: BoxDecoration(
                          color: const Color(0xff1E293B),

                          borderRadius: BorderRadius.circular(24),

                          border: Border.all(
                            color: Colors.white.withOpacity(0.04),
                          ),
                        ),

                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 32,

                                  backgroundColor: const Color(0xff4F46E5),

                                  child: Text(
                                    user.name[0].toUpperCase(),

                                    style: const TextStyle(
                                      fontSize: 24,

                                      fontWeight: FontWeight.bold,

                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                Positioned(
                                  right: 2,

                                  bottom: 2,

                                  child: Container(
                                    width: 14,

                                    height: 14,

                                    decoration: BoxDecoration(
                                      color: user.isOnline
                                          ? const Color(0xff10B981)
                                          : Colors.red,

                                      shape: BoxShape.circle,

                                      border: Border.all(
                                        color: const Color(0xff1E293B),

                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Text(
                                    user.name,

                                    style: const TextStyle(
                                      color: Colors.white,

                                      fontSize: 18,

                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    user.email,

                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.6),

                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                _buildCallButton(
                                  icon: Icons.call,

                                  color: const Color(0xff10B981),

                                  onTap: () async {
                                    String channelId = await context
                                        .read<CallProvider>()
                                        .startAudioCall(
                                          callerId: currentUser!.uid,

                                          callerName: currentUser.email ?? '',

                                          receiverId: user.uid,
                                        );

                                    if (context.mounted) {
                                      Navigator.push(
                                        context,

                                        MaterialPageRoute(
                                          builder: (_) => CallScreen(
                                            isVideo: false,
                                            receiverName: user.name,

                                            channelId: channelId,

                                            isReceiver: false,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),

                                const SizedBox(width: 12),

                                _buildCallButton(
                                  icon: Icons.videocam_rounded,

                                  color: const Color(0xff4F46E5),

                                  onTap: () async {
                                    String channelId = await context
                                        .read<CallProvider>()
                                        .startVideoCall(
                                          callerId: currentUser!.uid,

                                          callerName: currentUser.email ?? '',

                                          receiverId: user.uid,
                                        );

                                    if (context.mounted) {
                                      Navigator.push(
                                        context,

                                        MaterialPageRoute(
                                          builder: (_) => CallScreen(
                                            receiverName: user.name,

                                            channelId: channelId,

                                            isReceiver: false,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildCallButton({
    required IconData icon,

    required Color color,

    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        height: 46,

        width: 46,

        decoration: BoxDecoration(
          color: color,

          borderRadius: BorderRadius.circular(14),
        ),

        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}
