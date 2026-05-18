// import 'package:agora_calling_app/providers/auth_provider.dart';
// import 'package:agora_calling_app/screens/call/incoming_call_screen.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// import 'firebase_options.dart';
// import 'providers/user_provider.dart';
// import 'providers/call_provider.dart';
// import 'screens/splash_screen.dart';

// // ✅ Handle background notifications
// @pragma('vm:entry-point')
// Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
//   print('📩 Background notification received: ${message.notification?.title}');
// }

// // ✅ Global navigator key
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );

//   // ✅ Register background handler
//   FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

//   // ✅ Handle notification when app is terminated
//   final initialMessage = await FirebaseMessaging.instance.getInitialMessage();
//   if (initialMessage != null) {
//     _handleNotificationTap(initialMessage);
//   }

//   runApp(const MyApp());
// }

// // ✅ Open IncomingCallScreen from notification
// void _handleNotificationTap(RemoteMessage message) {
//   final data = message.data;
//   final channelId = data['channelId'];
//   final callerName = data['callerName'];
//   final callId = data['callId'];

//   if (channelId != null && callerName != null && callId != null) {
//     navigatorKey.currentState?.push(
//       MaterialPageRoute(
//         builder: (_) => IncomingCallScreen(
//           callerName: callerName,
//           channelId: channelId,
//           callId: callId,
//         ),
//       ),
//     );
//   }
// }

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {

//   @override
//   void initState() {
//     super.initState();

//     // ✅ Refresh token when it changes
//     FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
//       final uid = FirebaseAuth.instance.currentUser?.uid;
//       if (uid != null) {
//         await FirebaseFirestore.instance
//             .collection('users')
//             .doc(uid)
//             .set({'fcmToken': newToken}, SetOptions(merge: true));
//         print('✅ FCM Token refreshed: $newToken');
//       }
//     });

//     // ✅ Handle notification tap when app is in background
//     FirebaseMessaging.onMessageOpenedApp.listen((message) {
//       _handleNotificationTap(message);
//     });

//     // ✅ Handle notification when app is in foreground
//     FirebaseMessaging.onMessage.listen((message) {
//       print('📩 Foreground notification: ${message.notification?.title}');
//       // Firestore listener already handles IncomingCallScreen
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => AuthController()),
//         ChangeNotifierProvider(create: (_) => UserProvider()),
//         ChangeNotifierProvider(create: (_) => CallProvider()),
//       ],
//       child: MaterialApp(
//         debugShowCheckedModeBanner: false,
//         navigatorKey: navigatorKey, // ✅ important
//         theme: ThemeData(
//           primarySwatch: Colors.blue,
//         ),
//         home: const SplashScreen(),
//       ),
//     );
//   }
// }



import 'package:agora_calling_app/providers/auth_provider.dart';
import 'package:agora_calling_app/screens/call/incoming_call_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/user_provider.dart';
import 'providers/call_provider.dart';
import 'screens/splash_screen.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {

  await Firebase.initializeApp(
    options:
        DefaultFirebaseOptions
            .currentPlatform,
  );
}

final GlobalKey<NavigatorState>
navigatorKey =
    GlobalKey<NavigatorState>();

void main() async {

  WidgetsFlutterBinding
      .ensureInitialized();

  await Firebase.initializeApp(

    options:
        DefaultFirebaseOptions
            .currentPlatform,
  );

  FirebaseMessaging
      .onBackgroundMessage(

    _firebaseMessagingBackgroundHandler,
  );

  final initialMessage =
      await FirebaseMessaging
          .instance
          .getInitialMessage();

  if (initialMessage != null) {

    _handleNotificationTap(
      initialMessage,
    );
  }

  runApp(const MyApp());
}

void _handleNotificationTap(
  RemoteMessage message,
) {

  final data = message.data;

  final channelId =
      data['channelId'];

  final callerName =
      data['callerName'];

  final callId =
      data['callId'];

  final isVideo =
      data['isVideo'] == 'true';

  if (channelId != null &&
      callerName != null &&
      callId != null) {

    navigatorKey.currentState
        ?.push(

      MaterialPageRoute(

        builder: (_) =>
            IncomingCallScreen(

          callerName:
              callerName,

          channelId:
              channelId,

          callId:
              callId,

          isVideo:
              isVideo,
        ),
      ),
    );
  }
}

class MyApp
    extends StatefulWidget {

  const MyApp({
    super.key,
  });

  @override
  State<MyApp> createState() =>
      _MyAppState();
}

class _MyAppState
    extends State<MyApp> {

  @override
  void initState() {

    super.initState();

    FirebaseMessaging.instance
        .onTokenRefresh
        .listen((newToken) async {

      final uid =
          FirebaseAuth
              .instance
              .currentUser
              ?.uid;

      if (uid != null) {

        await FirebaseFirestore
            .instance
            .collection('users')
            .doc(uid)
            .set({

          'fcmToken':
              newToken,

        }, SetOptions(
          merge: true,
        ));
      }
    });

    FirebaseMessaging
        .onMessageOpenedApp
        .listen((message) {

      _handleNotificationTap(
        message,
      );
    });
  }

  @override
  Widget build(BuildContext context) {

    return MultiProvider(

      providers: [

        ChangeNotifierProvider(
          create: (_) =>
              AuthController(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              UserProvider(),
        ),

        ChangeNotifierProvider(
          create: (_) =>
              CallProvider(),
        ),
      ],

      child: MaterialApp(

        debugShowCheckedModeBanner:
            false,

        navigatorKey:
            navigatorKey,

        theme: ThemeData(
          primarySwatch:
              Colors.blue,
        ),

        home:
            const SplashScreen(),
      ),
    );
  }
}