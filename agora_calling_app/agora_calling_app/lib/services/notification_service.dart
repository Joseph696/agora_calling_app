import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  static const _scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

  // Get access token from service account
  static Future<String> _getAccessToken() async {
    final jsonString = await rootBundle.loadString('assets/service_account.json');
    final jsonData = json.decode(jsonString);

    final accountCredentials = ServiceAccountCredentials.fromJson(jsonData);
    final client = await clientViaServiceAccount(accountCredentials, _scopes);
    final token = client.credentials.accessToken.data;
    client.close();
    return token;
  }

  // Send call notification to receiver
  static Future<void> sendCallNotification({
    required String receiverFcmToken,
    required String callerName,
    required String channelId,
    required String callId,
  }) async {
    try {
      final accessToken = await _getAccessToken();

      // Get project ID from service account
      final jsonString = await rootBundle.loadString('assets/service_account.json');
      final jsonData = json.decode(jsonString);
      final projectId = jsonData['project_id'];

      final url = Uri.parse(
        'https://fcm.googleapis.com/v1/projects/$projectId/messages:send',
      );

      final message = {
        'message': {
          'token': receiverFcmToken,
          'notification': {
            'title': 'Incoming Call 📞',
            'body': '$callerName is calling you...',
          },
          'data': {
            'channelId': channelId,
            'callerName': callerName,
            'callId': callId,
            'type': 'incoming_call',
          },
          'android': {
            'priority': 'high',
            'notification': {
              'channel_id': 'incoming_call_channel',
              'sound': 'default',
            },
          },
        },
      };

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(message),
      );

      if (response.statusCode == 200) {
        print('✅ Notification sent successfully');
      } else {
        print('❌ Notification failed: ${response.body}');
      }
    } catch (e) {
      print('❌ Notification error: $e');
    }
  }
}