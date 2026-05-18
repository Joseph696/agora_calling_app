import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CallHistoryScreen extends StatelessWidget {
  const CallHistoryScreen({super.key});

  String _timeAgo(Timestamp? timestamp) {
    if (timestamp == null) return 'Unknown time';
    final now = DateTime.now();
    final diff = now.difference(timestamp.toDate());

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} hours ago';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return DateFormat('dd MMM yyyy').format(timestamp.toDate());
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'connected':
        return const Color(0xFF10B981);
      case 'rejected':
        return const Color(0xFFEF4444);
      case 'ended':
        return const Color(0xFF4F46E5);
      case 'ringing':
        return const Color(0xFFF59E0B);
      default:
        return Colors.grey;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'connected':
        return Icons.call;
      case 'rejected':
        return Icons.call_missed;
      case 'ended':
        return Icons.call_end;
      case 'ringing':
        return Icons.phone_missed;
      default:
        return Icons.call;
    }
  }

  String _statusText(String status) {
    switch (status) {
      case 'connected':
        return 'Connected';
      case 'rejected':
        return 'Rejected';
      case 'ended':
        return 'Ended';
      case 'ringing':
        return 'Missed';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    // ✅ null safe
    final currentUid = FirebaseAuth.instance.currentUser?.uid;

    if (currentUid == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: Text('Not logged in', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        elevation: 0,
        title: const Text(
          'Call History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('calls')
            .where('receiverId', isEqualTo: currentUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF4F46E5)),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.05),
                    ),
                    child: const Icon(
                      Icons.history,
                      size: 50,
                      color: Colors.white24,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No call history yet',
                    style: TextStyle(color: Colors.white54, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Your call history will appear here',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.3),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }

          // ✅ Sort safely — handles null timestamps
          final calls = snapshot.data!.docs
            ..sort((a, b) {
              final aTime = (a.data() as Map)['timestamp'] as Timestamp?;
              final bTime = (b.data() as Map)['timestamp'] as Timestamp?;
              if (aTime == null) return 1;
              if (bTime == null) return -1;
              return bTime.compareTo(aTime);
            });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: calls.length,
            itemBuilder: (context, index) {
              final data = calls[index].data() as Map<String, dynamic>;
              final callerName = data['callerName'] ?? 'Unknown';
              final isVideo = data['isVideo'] ?? false;
              final status = data['status'] ?? 'unknown';
              final timestamp = data['timestamp'] as Timestamp?;

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A2E),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.06),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _statusColor(status).withOpacity(0.15),
                    ),
                    child: Icon(
                      _statusIcon(status),
                      color: _statusColor(status),
                      size: 22,
                    ),
                  ),
                  title: Text(
                    callerName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            isVideo ? Icons.videocam : Icons.call,
                            size: 13,
                            color: Colors.white38,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isVideo ? 'Video Call' : 'Audio Call',
                            style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _statusText(status),
                          style: TextStyle(
                            color: _statusColor(status),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
